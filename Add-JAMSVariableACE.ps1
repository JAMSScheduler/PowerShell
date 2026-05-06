#Requires -Version 5.1
<#
.SYNOPSIS
    Adds a full-access ACE for a specified domain user to every JAMS Variable
    in every folder, across the entire JAMS server.

.DESCRIPTION
    Connects to a JAMS server, enumerates all folders recursively to collect
    variable paths, then for each variable uses Get-Item to fetch the full
    object (including its complete ACL) before appending the new ACE and
    calling Update(). Existing ACEs for other users are never modified.

.PARAMETER JAMSServer
    Hostname or IP of the JAMS server. Defaults to "localhost".

.PARAMETER TargetUser
    Domain user to grant access in DOMAIN\Username format.
    Example: "CORP\jsmith"

.PARAMETER Credential
    Optional PSCredential for connecting to the JAMS server.
    When omitted, the current Windows identity is used.

.PARAMETER WhatIf
    Standard PowerShell -WhatIf support. Shows what would happen without
    making any changes.

.PARAMETER ReportPath
    Optional path for a CSV summary report.
    Example: "C:\Logs\JAMSVariableACL_Report.csv"

.EXAMPLE
    .\Add-JAMSVariableACE.ps1 -JAMSServer "localhost" -TargetUser "CORP\jsmith"

.EXAMPLE
    $cred = Get-Credential
    .\Add-JAMSVariableACE.ps1 -JAMSServer "jams-prod" -TargetUser "CORP\jsmith" -Credential $cred -ReportPath "C:\Logs\ACLReport.csv"

.EXAMPLE
    .\Add-JAMSVariableACE.ps1 -JAMSServer "jams-prod" -TargetUser "CORP\jsmith" -WhatIf

.NOTES
    Prerequisites:
      - JAMS Client installed with the JAMS PowerShell module available.
      - The executing account needs at least Modify Security rights on each
        variable, or JAMS administrator rights.
      - Tested against JAMS 7.x.
      - Based on the official JAMS ACE pattern:
          $variable = Get-Item JAMS::localhost\Folder\VarName
          $ace = New-Object MVPSI.JAMS.GenericACE
          $ace.Identifier = "DOMAIN\User"
          $ace.AccessBits = ([MVPSI.JAMS.VariableAccess]::Change -bor ...)
          $variable.ACL.GenericACL.Add($ace)
          $variable.Update()
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
    [string]$ReportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# 1. Load the JAMS PowerShell module
# ---------------------------------------------------------------------------
Write-Verbose "Loading JAMS module..."

if (Get-Module -ListAvailable -Name JAMS -ErrorAction SilentlyContinue) {
    Import-Module JAMS -ErrorAction Stop
    Write-Verbose "JAMS PowerShell module loaded."
} else {
    throw "The JAMS PowerShell module was not found. Ensure the JAMS Client is installed on this machine."
}

# ---------------------------------------------------------------------------
# 2. Mount the JAMS PSDrive
#    The drive name encodes the server so multiple servers can coexist.
#    Format: JAMS::<server>\<folder>\<variable>  -- matches the official example.
# ---------------------------------------------------------------------------
$driveName = "JD"

Write-Verbose "Mounting JAMS PSDrive '$driveName' -> $JAMSServer"

$psDriveParams = @{
    Name        = $driveName
    PSProvider  = "JAMS"
    Root        = $JAMSServer
    ErrorAction = "SilentlyContinue"   # idempotent if already mounted
}
if ($Credential) {
    $psDriveParams['Credential'] = $Credential
}
New-PSDrive @psDriveParams | Out-Null

if (-not (Get-PSDrive -Name $driveName -ErrorAction SilentlyContinue)) {
    throw "Failed to mount JAMS PSDrive for server '$JAMSServer'. Check the server name, credentials, and that the JAMS service is running."
}

Write-Verbose "PSDrive ${driveName}:\ mounted successfully."

# ---------------------------------------------------------------------------
# 3. Enumerate ALL variable paths across ALL folders (recursive)
#    Get-ChildItem is used only to discover paths -- the lightweight objects
#    it returns are NOT used for ACL work.
#    Get-Item is called per-variable to fetch the full object with its ACL.
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Enumerating all JAMS Variables on '$JAMSServer'..." -ForegroundColor Cyan

$varPaths = Get-ChildItem "${driveName}:\" -Recurse -ObjectType variable -ErrorAction SilentlyContinue |
            Where-Object  { $_.PSObject.Properties['PSPath'] } |
            ForEach-Object {
                # PSPath already contains the full provider path that Get-Item
                # needs (e.g. JAMS::localhost\Jobs\TestVar). Use it as-is.
                $_.PSPath
            }

if (-not $varPaths -or @($varPaths).Count -eq 0) {
    Write-Warning "No JAMS Variables found on '$JAMSServer'. Nothing to update."
    Remove-PSDrive $driveName -ErrorAction SilentlyContinue
    exit 0
}

Write-Host "Found $(@($varPaths).Count) variable(s) across all folders." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 4. Process each variable
# ---------------------------------------------------------------------------
$results      = [System.Collections.Generic.List[PSCustomObject]]::new()
$countAdded   = 0
$countSkipped = 0
$countError   = 0

foreach ($path in $varPaths) {

    try {
        # Get-Item fetches the FULL variable object from the server,
        # including its complete, populated ACL -- this is the key difference
        # from Get-ChildItem which returns lightweight enumeration objects
        # with an empty ACL.
        # Use SilentlyContinue first to test existence, then Stop for real work.
        $variable = Get-Item $path -ErrorAction SilentlyContinue

        # If Get-Item returned nothing the path does not exist in the provider
        # (e.g. Dates calendar entries) -- skip silently, not an error.
        if (-not $variable) {
            Write-Verbose "SKIP  '$path' -- path not found in JAMS provider."
            continue
        }

        $variable = Get-Item $path -ErrorAction Stop

        # Skip any object that does not have an ACL property -- the JAMS
        # provider returns non-Variable types (Methods, Dates, Calendars,
        # Security, Times, etc.) that have no ACL and cannot be updated.
        if (-not $variable.PSObject.Properties['ACL']) {
            Write-Verbose "SKIP  '$path' -- not a Variable (no ACL property)."
            continue
        }

        # Check whether TargetUser already has an ACE -- if so, skip entirely
        # so we never touch ACEs belonging to other users.
        $existingAce = $variable.ACL.GenericACL |
                       Where-Object { $_.Identifier -eq $TargetUser }

        if ($existingAce) {
            Write-Verbose "SKIP  '$path' -- '$TargetUser' already has an ACE."
            $results.Add([PSCustomObject]@{
                Variable = $path
                Status   = "Skipped (ACE already exists)"
                User     = $TargetUser
            })
            $countSkipped++
            continue
        }

        # Build the new ACE -- full access across all five VariableAccess rights
        if ($PSCmdlet.ShouldProcess($path, "Add full-access ACE for '$TargetUser'")) {

            $ace            = New-Object MVPSI.JAMS.GenericACE
            $ace.Identifier = $TargetUser
            $ace.AccessBits = (
                [MVPSI.JAMS.VariableAccess]::Change  -bor
                [MVPSI.JAMS.VariableAccess]::Control -bor
                [MVPSI.JAMS.VariableAccess]::Decrypt -bor
                [MVPSI.JAMS.VariableAccess]::Delete  -bor
                [MVPSI.JAMS.VariableAccess]::Inquire
            )

            # Append the ACE to the existing list -- does not affect other ACEs
            $variable.ACL.GenericACL.Add($ace)

            # Persist to the server
            $variable.Update()

            Write-Host "ADDED  $path" -ForegroundColor Green
            $results.Add([PSCustomObject]@{
                Variable = $path
                Status   = "ACE Added"
                User     = $TargetUser
            })
            $countAdded++
        }

    } catch {
        $errMsg = $_.Exception.Message
        Write-Warning "ERROR  '$path': $errMsg"
        $results.Add([PSCustomObject]@{
            Variable = $path
            Status   = "ERROR: $errMsg"
            User     = $TargetUser
        })
        $countError++
    }
}

# ---------------------------------------------------------------------------
# 5. Clean up
# ---------------------------------------------------------------------------
Remove-PSDrive $driveName -ErrorAction SilentlyContinue

# ---------------------------------------------------------------------------
# 6. Summary
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=================== Summary ===================" -ForegroundColor Cyan
Write-Host "  Server  : $JAMSServer"
Write-Host "  User    : $TargetUser"
Write-Host "  Found   : $(@($varPaths).Count) object(s) enumerated"
Write-Host "  Updated : $($countAdded + $countSkipped) variable(s) processed"
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
