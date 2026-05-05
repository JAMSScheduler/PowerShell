#Requires -Version 5.1
<#
.SYNOPSIS
    Adds a full-access ACE for a specified domain user to every JAMS Variable
    in every folder, across the entire JAMS server.

.DESCRIPTION
    Connects to a JAMS server, enumerates all folders recursively, then for
    each Variable found:
      1. Checks whether the target user already has an ACE (skips if present
         and -Force is not specified).
      2. Builds a GenericACE granting all five VariableAccess rights
         (Change, Control, Decrypt, Delete, Inquire) -- equivalent to Full Access.
      3. Adds the ACE to the variable's ACL and saves it back to the server.

    A summary is printed to the console and optionally written to a CSV file.

.PARAMETER JAMSServer
    Hostname or IP of the JAMS server. Defaults to "localhost".

.PARAMETER TargetUser
    Domain user to grant access in DOMAIN\Username format.
    Example: "CORP\jsmith"

.PARAMETER Credential
    Optional PSCredential for connecting to the JAMS server.
    When omitted, the current Windows identity is used.

.PARAMETER Force
    If specified, overwrites an existing ACE for TargetUser rather than
    skipping that variable.

.PARAMETER WhatIf
    Standard PowerShell -WhatIf support. Shows what would happen without
    making any changes.

.PARAMETER ReportPath
    Optional path for a CSV summary report.
    Example: "C:\Logs\JAMSVariableACL_Report.csv"

.EXAMPLE
    .\Add-JAMSVariableACE.ps1 -JAMSServer "jams-prod" -TargetUser "CORP\jsmith"

.EXAMPLE
    $cred = Get-Credential
    .\Add-JAMSVariableACE.ps1 -JAMSServer "jams-prod" -TargetUser "CORP\jsmith" -Credential $cred -ReportPath "C:\Logs\ACLReport.csv"

.EXAMPLE
    .\Add-JAMSVariableACE.ps1 -JAMSServer "jams-prod" -TargetUser "CORP\jsmith" -WhatIf

.NOTES
    Prerequisites:
      - JAMS Client installed (default: C:\Program Files\MVPSI\JAMS\Client\)
        OR the JAMS PowerShell module available via Import-Module JAMS.
      - The executing account needs at least Modify Security rights on each
        variable's parent folder, or JAMS administrator rights.
      - Tested against JAMS 7.x.
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $false)]
    [string]$JAMSServer = "localhost",

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[^\\]+\\[^\\]+$')]
    [string]$TargetUser,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.PSCredential]$Credential,

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [string]$ReportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Helper -- builds the full-access bit mask AFTER JAMS is loaded.
# Wrapping in a function means the [MVPSI.JAMS.VariableAccess] type is only
# resolved when the function is called, not when the script is parsed.
# ---------------------------------------------------------------------------
function Get-FullAccessBits {
    return (
        [MVPSI.JAMS.VariableAccess]::Change  -bor
        [MVPSI.JAMS.VariableAccess]::Control -bor
        [MVPSI.JAMS.VariableAccess]::Decrypt -bor
        [MVPSI.JAMS.VariableAccess]::Delete  -bor
        [MVPSI.JAMS.VariableAccess]::Inquire
    )
}

# ---------------------------------------------------------------------------
# 1. Load JAMS -- prefer the PowerShell module; fall back to raw assembly
# ---------------------------------------------------------------------------
Write-Verbose "Loading JAMS module/assemblies..."

$moduleLoaded = $false

if (Get-Module -ListAvailable -Name JAMS -ErrorAction SilentlyContinue) {
    Import-Module JAMS -ErrorAction Stop
    $moduleLoaded = $true
    Write-Verbose "JAMS PowerShell module loaded."
}

if (-not $moduleLoaded) {
    $JAMSClientPath = "C:\Program Files\MVPSI\JAMS\Client"
    $dll = Join-Path $JAMSClientPath "MVPSI.JAMS.dll"

    if (-not (Test-Path $dll)) {
        throw "JAMS module not found and assembly not at '$dll'. Ensure the JAMS Client is installed."
    }

    Add-Type -Path $dll
    Write-Verbose "JAMS assembly loaded from '$dll'."
}

# ---------------------------------------------------------------------------
# 2. Mount the JAMS PSDrive
# ---------------------------------------------------------------------------
Write-Verbose "Mounting JAMS PSDrive -> $JAMSServer"

$psDriveParams = @{
    Name        = "JD"
    PSProvider  = "JAMS"
    Root        = $JAMSServer
    ErrorAction = "SilentlyContinue"
}
if ($Credential) {
    $psDriveParams['Credential'] = $Credential
}
New-PSDrive @psDriveParams | Out-Null

if (-not (Get-PSDrive -Name JD -ErrorAction SilentlyContinue)) {
    throw "Failed to mount JAMS PSDrive for server '$JAMSServer'. Check server name, credentials, and JAMS service availability."
}

Write-Verbose "PSDrive JD:\ mounted successfully."

# ---------------------------------------------------------------------------
# 3. Enumerate ALL variables across ALL folders (recursive)
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Enumerating all JAMS Variables on '$JAMSServer'..." -ForegroundColor Cyan

$allVariables = Get-ChildItem JD:\ -Recurse -ObjectType variable -ErrorAction SilentlyContinue |
                Where-Object { $_ -is [MVPSI.JAMS.Variable] }

if (-not $allVariables -or $allVariables.Count -eq 0) {
    Write-Warning "No JAMS Variables found on '$JAMSServer'. Nothing to update."
    Remove-PSDrive JD -ErrorAction SilentlyContinue
    exit 0
}

Write-Host "Found $($allVariables.Count) variable(s) across all folders." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 4. Process each variable
# ---------------------------------------------------------------------------

# Resolve access bits now that the JAMS module is loaded
$accessBits = Get-FullAccessBits

$results      = [System.Collections.Generic.List[PSCustomObject]]::new()
$countAdded   = 0
$countSkipped = 0
$countError   = 0

foreach ($var in $allVariables) {

    # Build a display path -- use PSPath as fallback if ParentFolderName is missing
    if ($var.PSObject.Properties['ParentFolderName'] -and $var.ParentFolderName) {
        $varPath = "$($var.ParentFolderName)\$($var.Name)"
    } else {
        $varPath = $var.PSPath -replace '^.*?::', ''
    }

    try {
        # Check whether TargetUser already has an ACE on this variable
        $existingAce = $var.ACL.GenericACL |
                       Where-Object { $_.Identifier -eq $TargetUser }

        if ($existingAce -and -not $Force) {
            Write-Verbose "SKIP  '$varPath' -- '$TargetUser' already has an ACE."
            $results.Add([PSCustomObject]@{
                Variable = $varPath
                Status   = "Skipped (ACE already exists)"
                User     = $TargetUser
            })
            $countSkipped++
            continue
        }

        if ($existingAce -and $Force) {
            $var.ACL.GenericACL.Remove($existingAce) | Out-Null
            Write-Verbose "FORCE '$varPath' -- removed existing ACE for '$TargetUser', will replace."
        }

        # Build and attach the new ACE
        if ($PSCmdlet.ShouldProcess("Variable '$varPath' on '$JAMSServer'", "Add full-access ACE for '$TargetUser'")) {

            $ace            = New-Object MVPSI.JAMS.GenericACE
            $ace.Identifier = $TargetUser
            $ace.AccessBits = $accessBits

            $var.ACL.GenericACL.Add($ace)
            $var.Update()

            Write-Host "ADDED '$varPath' -> '$TargetUser'" -ForegroundColor Green
            $results.Add([PSCustomObject]@{
                Variable = $varPath
                Status   = "ACE Added"
                User     = $TargetUser
            })
            $countAdded++
        }

    } catch {
        $errMsg = $_.Exception.Message
        Write-Warning "ERROR on '$varPath': $errMsg"
        $results.Add([PSCustomObject]@{
            Variable = $varPath
            Status   = "ERROR: $errMsg"
            User     = $TargetUser
        })
        $countError++
    }
}

# ---------------------------------------------------------------------------
# 5. Clean up
# ---------------------------------------------------------------------------
Remove-PSDrive JD -ErrorAction SilentlyContinue

# ---------------------------------------------------------------------------
# 6. Summary
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=================== Summary ===================" -ForegroundColor Cyan
Write-Host "  Server  : $JAMSServer"
Write-Host "  User    : $TargetUser"
Write-Host "  Total   : $($allVariables.Count) variable(s)"
Write-Host "  Added   : $countAdded"   -ForegroundColor Green
Write-Host "  Skipped : $countSkipped" -ForegroundColor Yellow

if ($countError -gt 0) {
    Write-Host "  Errors  : $countError" -ForegroundColor Red
} else {
    Write-Host "  Errors  : $countError"
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

if ($ReportPath) {
    try {
        $results | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
        Write-Host "Report saved to: $ReportPath" -ForegroundColor Cyan
    } catch {
        Write-Warning ("Could not write report to '" + $ReportPath + "': " + $_.Exception.Message)
    }
}
