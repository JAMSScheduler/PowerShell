<#
.Synopsis
   Wait for the specified files
.DESCRIPTION
   Wait for the specified files to appear and optionally, to be available.
.EXAMPLE
   WaitFor-File Xyzzy.dat
.EXAMPLE
   WaitFor-File *.txt
#>
function Wait-File
{
    [CmdletBinding(DefaultParameterSetName='FileSpec', 
                  SupportsShouldProcess=$false, 
                  PositionalBinding=$false,
                  HelpUri = 'http://support.JAMSScheduler.com/',
                  ConfirmImpact='None')]
    [OutputType([System.IO.FileSystemInfo])]
    Param
    (
        # Specify the file that you want to wait for
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='FileSpec')]
        [ValidateNotNullOrEmpty()]
        $FileSpecification,

        # -Timeout can be used to specify the maximum amount of time to wait
        [Parameter(ParameterSetName='FileSpec')]
        [TimeSpan]
        $timeout="0.08:00",

        # -Interval can be used to adjust the delay between checking for the specified files. The default is 3 seconds.
        [Parameter(ParameterSetName='FileSpec')]
        [ValidateLength(0,9999)]
        [int]
        $interval=3,

        # -Available indicates that you want to wait until the files are actually available
        [Parameter(ParameterSetName='FileSpec')]
        [Switch]
        $available
    )

    Begin
    {
        Write-Verbose "Started waiting for files at $(Get-Date -format 'u')"
        Write-Verbose "Timeout is set to $timeout"
        $absoluteTimeout = Get-Date 
    }
    Process
    {
        $duration = 0
        $timeoutSeconds = $timeout.TotalSeconds
        $weHaveFiles = $false
        
        Write-Verbose "Waiting for files that match: $FileSpecification"
        do
        {
            $matchedFiles = @(Get-ChildItem $FileSpecification -ErrorAction SilentlyContinue -ErrorVariable gciError)

            #
            #  We expect PathNotFound errors so we will suppress them and display others
            #
            foreach($err in $gciError)
            {
                if (-not $err.FullyQualifiedErrorId.StartsWith("PathNotFound,"))
                {
                    Write-Error $err
                }
            }

            if (($matchedFiles.Count -gt 0) -and ($gciError.Count -eq 0))
            {
                Write-Verbose "$matchedFiles files found"

                #
                #  Make sure they are available
                #
                $weHaveFiles = $true
                if ($available)
                {
                    foreach($match in $matchedFiles)
                    {
                        try
                        {
                            $match.open("open")
                            $match.close
                            Write-Verbose "$match Available"
                        }
                        catch
                        {
                            Write-Verbose "$match not available"
                            $weHaveFiles = $false
                        }
                    }
                }
            }
            else
            {
                if ($duration -gt $timeoutSeconds)
                {
                    throw "Timeout while waiting for files"
                }
                Start-Sleep -seconds $interval
                $duration+= $interval
            }
        } while(-not $weHaveFiles)

    }
    End
    {
    }
}

<#
.Synopsis
   Deletes all objects in a JAMS Folder
.DESCRIPTION
   Deletes all objects in a JAMS Folder including subfolders.
.EXAMPLE
   Remove-AllJAMSObjects JAMS::localhost\Folder1\Folder2\
.EXAMPLE
   Remove-AllJAMSObjects JAMS::localhost\Folder1\Folder2\ -Verbose
#>
function Remove-JAMSObjects
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $path
    )

    Begin
    {
        Import-Module JAMS
    }
    Process
    {
        $ConfirmPreference = "None"
        $previousItemCount = 0;
        $loopCount = 0
        do
        {
            $items = Get-ChildItem $path -Recurse
            if ($items.Count -eq $previousItemCount)
            {
                $loopCount = $loopCount + 1
            }
            else
            {
                $loopCount = 0
            }
            $previousItemCount = $items.Count
            foreach($item in $items)
            {
                Write-Verbose "Deleting $item - $($item.QualifiedName)"
                $item | Remove-Item -Recurse -ErrorAction Continue -Confirm:$false
            }
            write-verbose "Item count: $($items.Count), loop count: $loopCount"
        } while (($items.Count -gt 0) -and ($loopCount -lt 10))
    }
    End
    {
    }
}

<#
.Synopsis
   Will test if an Agent is currently online or offline
.DESCRIPTION
   Will return Online or Offline for the status of a JAMS Agent running on Windows or Linux
.EXAMPLE
   $AgentStatus = Test-JAMSAgent -Name SQLAgent1
.EXAMPLE
   $AgentStatus = Test-JAMSAgent -Name SQLAgent1 -Server MVPJAMSProd
#>
function Test-JAMSAgent ([string]$Name = "*", [string]$Server = "localhost"){
    #
    #  Create a list of JAMS Agents
    #
    $agentList = Get-JAMSAgent $Name
    #
    #  Loop through agent list
    #
    Foreach($agent in $agentList){
        #
        #   Write out message to console
        #
        Write-Host 'Checking Agent on' $agent.AgentName
        #
        #   Check agent's Platform property
        #
        if($agent.Platform -eq 'Windows'){
            #
            # Check if the Agent Machine is Online
            #
            if(Test-Connection -ComputerName $agent.AgentName –Quiet –Count 2){
                #
                #   Get service Object
                #
                $agentObject = Get-Service *JAMSAgent -ComputerName $agent.AgentName
                #
                #   Check if JAMSAgent is Stopped
                #
                if($agentObject.Status -eq 'Stopped'){
                    Return "Offline"
                    Write-Host "Enabling JAMS Agent Service on $agentObject.MachineName"
                    #
                    #   Start service with Object as input
                    #
                    Start-Service -InputObject $agentObject
                }
                Return "Online"
            } else {
                Return "Offline"
            }
        }else{
            #
            #   Non-windows do a Test-Connection to see if it responds
            #
            if(Test-Connection -ComputerName $agent.AgentName –Quiet –Count 2){
                Return "Online"
            }else{
                #
                #   Write message to console that server is down
                #
                Return "Offline"
            }
        }
    }
}

<#
.Synopsis
   Set permissions on JAMS folders
.DESCRIPTION
   Allows you to programmatically set and define permissions to JAMS Folders
.EXAMPLE
   Set-JAMSPermission -folderName 'Samples' -abort $true -addJobs $true -change $true -changeJobs $true -control $true -debugPerm $true -delete $true -deleteJobs $true -inquire $true -inquireJobs $true -manage $true -monitor $true -submit $true -user 'MVP\Admins'
.EXAMPLE
   Set-JAMSPermission -folderName 'Samples' -abort $false -addJobs $false -change $false -changeJobs $false -control $false -debugPerm $false -delete $false -deleteJobs $false -inquire $true -inquireJobs $true -manage $false -monitor $true -submit $false -user 'MVP\Readers'
#>

function Set-JAMSPermission
{
    PARAM
    (
        [parameter(Mandatory=$True)]
        [STRING]$folderName,
        [parameter(Mandatory=$True)]
        [bool]$abort = $false,
        [parameter(Mandatory=$True)]
        [bool]$addJobs = $false,
        [parameter(Mandatory=$True)]
        [bool]$change = $false,
        [parameter(Mandatory=$True)]
        [bool]$changeJobs = $false,
        [parameter(Mandatory=$True)]
        [bool]$control = $false,
        [parameter(Mandatory=$True)]
        [bool]$debugPerm = $false,
        [parameter(Mandatory=$True)]
        [bool]$delete = $false,
        [parameter(Mandatory=$True)]
        [bool]$deleteJobs = $false,
        [parameter(Mandatory=$True)]
        [bool]$inquire = $false,
        [parameter(Mandatory=$True)]
        [bool]$inquireJobs = $false,
        [parameter(Mandatory=$True)]
        [bool]$manage = $false,
        [parameter(Mandatory=$True)]
        [bool]$monitor = $false,
        [parameter(Mandatory=$True)]
        [bool]$submit = $false,
        [parameter(Mandatory=$True)]
        [STRING]$user
    )
    begin {
    }
    
    process {
        if (Test-Path $folderName)
        {
            Write-Verbose "$folderName found."
            $Folder = Get-Item -Path $folderName
        }
        else
        {
            Write-Error "$folderName not found!"
        }

        $ace = New-Object MVPSI.JAMS.GenericACE
        $ace.Identifier = $user
    
        $ace.AccessBits = [MVPSI.JAMS.FolderAccess]([int][MVPSI.JAMS.FolderAccess]::Abort * $abort +
            [int][MVPSI.JAMS.FolderAccess]::AddJobs * $addJobs +
            [int][MVPSI.JAMS.FolderAccess]::changeJobs * $changeJobs +
            [int][MVPSI.JAMS.FolderAccess]::change * $change +
            [int][MVPSI.JAMS.FolderAccess]::control * $control +
            [int][MVPSI.JAMS.FolderAccess]::debug * $debugPerm +
            [int][MVPSI.JAMS.FolderAccess]::delete * $delete +
            [int][MVPSI.JAMS.FolderAccess]::deleteJobs * $deleteJobs +
            [int][MVPSI.JAMS.FolderAccess]::inquire * $inquire +
            [int][MVPSI.JAMS.FolderAccess]::inquireJobs * $inquireJobs +
            [int][MVPSI.JAMS.FolderAccess]::manage * $manage +
            [int][MVPSI.JAMS.FolderAccess]::monitor * $monitor +
            [int][MVPSI.JAMS.FolderAccess]::submit * $submit)

        $Folder.ACL.GenericACL.Add($ace)

        $Folder.Update()
    }
    end
    {
    }
}
