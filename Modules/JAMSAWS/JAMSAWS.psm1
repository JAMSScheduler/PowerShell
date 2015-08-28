<#
.Synopsis
   Start a list of your Amazon EC2 instances defined within a CSV file
.DESCRIPTION
   Used in conjunction with the Connect-JAMSAWSLogin cmdlet to parse a CSV file for a list of Amazon EC2 instances, check their status, start any that are offline, boot them up and then grab their Public IP address to be added to a Batch Queue.
.SYNTAX
   Start-JAMSEC2 -InputFile <String> -QueueName <String> -JobLimit <Int32> -StoredCredentials <String>
.EXAMPLE
   Start-JAMSEC2 -InputFile C:\AmazonEC2Instances.csv -QueueName AmazonEC2SQL -JobLimit 25 -StoredCredentials $AmazonAWS
#>
Function Start-JAMSEC2 {
    [CmdletBinding(SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://support.JAMSScheduler.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='InputFile')]
        [ValidateNotNullOrEmpty()]
        [String]$InputFile,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$QueueName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int]$JobLimit,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $StoredCredentials
    )

    Begin 
    {
        # Check and see if the AWSPowerShell and JAMS Modules have been loaded
        $Modules = Get-Module

        if (($Modules.Name -contains 'AWSPowerShell') -and ($Modules.Name -contains 'JAMS')) {
            Write-Verbose 'AWSPowerShell and JAMS Modules already loaded...'
        }
        else {
            Write-Verbose 'Loading the AWSPowerShell and JAMS Module...'

            Import-Module AWSPowerShell -WarningAction SilentlyContinue -ErrorVariable +ModError
            Import-Module JAMS -WarningAction SilentlyContinue -ErrorVariable +ModError

            foreach ($err in $ModError) {
                Write-Error $err
            }
        }
        
        Write-Verbose "Parsing $InputFile for Instance and Region data"
        
        # We are going to need a PS Drive for JAMS later
        New-PSDrive JD JAMS $JAMSDefaultServer
    }
    Process 
    {
        # Define our arrays
        $Instance = @()
        $Region = @()
        $Ainfo = @()
        $publicIP = @()
        $keys = @()

        # Hash table for instance names
        $InstanceTable = @{}

        # Import and parse the CSV file of our instances and regions
        Import-Csv $InputFile |`
        ForEach-Object {
            $InstanceTable.Add(('{0}|{1}' -f $_.Instance,$_.Region), 'OFF')
        }

        # How many instances did we pull in?
        Write-Debug $InstanceTable.Count

        foreach($val in $InstanceTable.Keys)
        {
            $keys += $val
        }

        # Iterate through our hash table and determine the status of each EC2 instance
        foreach($key in $keys)
        {
            $keyName = $key.Split('|')
            $instanceName = $keyName[0]
            $regionName = $keyName[1]

            Write-Verbose $instanceName
            Write-Verbose $regionName
    
            # Get the instance
            $InstanceTable[$key] = Get-EC2InstanceStatus -InstanceIds $instanceName -Credential $StoredCredentials -Region $regionName
        }

        foreach($key in $InstanceTable.Keys)
        {
            # Get the name
            $keyName = $key.Split('|')
            $instanceName = $keyName[0]
            $regionName = $keyName[1]

            # Get the object
            $instance = $InstanceTable[$key]

            $state = $instance.InstanceState.Name

            if ($state -eq 'running')
            {
                Write-Verbose "$instanceName is running."

                # Instance is already running, let's make sure we have the right IP and update our queue for it
                $publicIP += Get-EC2Instance -Instance $instanceName -Credential $StoredCredentials -Region $regionName
            }
            if ($state -eq $null)
            {
                Write-Verbose "$instanceName is not running."
                Start-EC2Instance -InstanceIds $instanceName -Credential $StoredCredentials -Region $regionName

                # Sleep for 5 seconds to give that instance enough time to get an IP
                Write-Verbose 'Sleeping for 5 seconds to get IP.'
                Start-Sleep 5

                $publicIP += Get-EC2Instance -Instance $instanceName -Credential $StoredCredentials -Region $regionName
            }
        }

        # Does our batch queue exist?
        if (!(Test-Path JD:\Queues\$QueueName)) {
            $Queue = New-Item JD:\Queues\$QueueName
        }
        else {
            $Queue = Get-ChildItem JD:\Queues\$QueueName
        }
        # Update our Batch Queue - we will iterate through our array of IP's to update each
        Write-Verbose $publicIP.Instances.Count

        $Queue.StartedOn.Clear()
        foreach($IP in $publicIP)
        {
            $queueIP = $IP.Instances.PublicIpAddress
            $Queue.StartedOn.Add("$queueIP")
        }
        $Queue.JobLimit = $JobLimit
        $Queue.Update()
    }
    End
    {
    }
}

<#
.Synopsis
   Stop a list of your Amazon EC2 instances defined within a CSV file
.DESCRIPTION
   Used in conjunction with the Connect-JAMSAWSLogin cmdlet to parse a CSV file for a list of Amazon EC2 instances, check their status and turn off any running instances.
.SYNTAX
   Stop-JAMSEC2 -InputFile <String> -StoredCredentials <String>
.EXAMPLE
   Stop-JAMSEC2 -InputFile C:\AmazonEC2Instances.csv -StoredCredentials $AmazonAWS
#>
Function Stop-JAMSEC2 {
    [CmdletBinding(SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://support.JAMSScheduler.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='InputFile')]
        [ValidateNotNullOrEmpty()]
        [String]$InputFile,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $StoredCredentials
    )

    Begin 
    {
        # Check and see if the AWSPowerShell Module has been loaded
        $Modules = Get-Module

        if ($Modules.Name -contains 'AWSPowerShell') {
            Write-Verbose 'AWSPowerShell Module already loaded...'
        }
        else {
            Write-Verbose 'Loading the AWSPowerShell Module...'

            Import-Module AWSPowerShell -WarningAction SilentlyContinue -ErrorVariable SQLModError

            foreach ($err in $SQLModError) {
                Write-Error $err
            }
        }
        
        Write-Verbose "Parsing $InputFile for Instance and Region data"
    }
    Process 
    {
        # Define our arrays
        $Instance = @()
        $Region = @()
        $keys = @()

        # Hash table for instance names
        $InstanceTable = @{}

        # Import and parse the CSV file of our instances and regions
        Import-Csv $InputFile |`
        ForEach-Object {
            $InstanceTable.Add(('{0}|{1}' -f $_.Instance,$_.Region), 'OFF')
        }

        # How many instances did we pull in?
        Write-Debug $InstanceTable.Count

        foreach($val in $InstanceTable.Keys)
        {
            $keys += $val
        }

        # Iterate through our hash table and determine the status of each EC2 instance
        foreach($key in $keys)
        {
            $keyName = $key.Split('|')
            $instanceName = $keyName[0]
            $regionName = $keyName[1]

            Write-Debug $instanceName
            Write-Debug $regionName
    
            # Get the instance
            $InstanceTable[$key] = Get-EC2InstanceStatus -InstanceIds $instanceName -Credential $StoredCredentials -Region $regionName
        }

        foreach($key in $InstanceTable.Keys)
        {
            # Get the name
            $keyName = $key.Split('|')
            $instanceName = $keyName[0]
            $regionName = $keyName[1]

            # Get the object
            $instance = $InstanceTable[$key]

            $state = $instance.InstanceState.Name

            if ($state -eq 'running')
            {
                Write-Verbose "$instanceName is running."

                # Instance is running, stop the EC2 instance
                Stop-EC2Instance -Instance $instanceName -Credential $StoredCredentials -Region $regionName | Out-Null
            }
            if ($state -eq $null)
            {
                Write-Verbose "$instanceName is not running."
            }
        }
    }
    End {}
}

<#
.Synopsis
   Connect to your instance of Amazon AWS
.DESCRIPTION
   Connect and store an Amazon AWS Session into a PowerShell variable utilizing a stored JAMS User
.SYNTAX
   Connect-JAMSAWSLogin -JAMSCredential AmazonAWSLogin -SessionName AmazonAWS
.EXAMPLE
   $AmazonAWS = Connect-JAMSAWSLogin -JAMSCredential AmazonAWSLogin -SessionName AmazonAWS
#>
Function Connect-JAMSAWSLogin {
    [CmdletBinding(SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://support.JAMSScheduler.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='JAMSCredential')]
        [ValidateNotNullOrEmpty()]
        [String]$JAMSCredential,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]$SessionName
    )
    Begin 
    {
        # Check and see if the AWSPowerShell and JAMS Modules have been loaded
        $Modules = Get-Module

        if (($Modules.Name -contains 'AWSPowerShell') -and ($Modules.Name -contains 'JAMS')) {
            Write-Verbose 'AWSPowerShell and JAMS Modules already loaded...'
        }
        else {
            Write-Verbose 'Loading the AWSPowerShell and JAMS Module...'

            Import-Module AWSPowerShell -WarningAction SilentlyContinue -ErrorVariable +ModError
            Import-Module JAMS -WarningAction SilentlyContinue -ErrorVariable +ModError

            foreach ($err in $ModError) {
                Write-Error $err
            }
        }
    }
    Process 
    {
        # Amazon EC2 Stored Credentials
        $secretKey = (Get-JAMSCredential $JAMSCredential).GetCredential($null,$null)
        $accessKey = (Get-JAMSCredential $JAMSCredential).UserName

        $creds = New-AWSCredentials -AccessKey $accessKey -SecretKey $secretKey.password

        # Cache our credentials for use by AWS.NET API
        Set-AWSCredentials -Credential $creds -StoreAs $SessionName

        $storedCred = $SessionName
        
        return $creds
    }
    End 
    {
    }
}

<#
        .Synopsis
        Wait for the specified files
        .DESCRIPTION
        Wait for the specified files and folders to become Present, Absent or Modified
        .EXAMPLE
        Wait-ForS3Item -Bucket DBBackup -Item SQLServer1.bak -BasedUpon Present -JAMSCredential SQLServerAdmin
        .EXAMPLE
        Wait-ForS3Item -Bucket DBBackup -Item DailyArchive -BasedUpon Absent -JAMSCredential SQLServerAdmin -IsFolder
#>
Add-Type -TypeDefinition @"
   public enum Validation
   {
        Present,
        Absent,
        Modified
   }
"@
function Wait-ForS3Item
{
    [CmdletBinding(DefaultParameterSetName='Bucket', 
                  SupportsShouldProcess=$false, 
                  PositionalBinding=$false,
                  HelpUri = 'http://support.JAMSScheduler.com/',
                  ConfirmImpact='None')]
    Param
    (
        # Specify the S3 Bucket
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Bucket')]
        [ValidateNotNullOrEmpty()]
        [String]$Bucket,
        
        # -Item is used to specify the specific item we'll be watching for
        [Parameter(Mandatory=$true,
                   Position=1,
                   ParameterSetName='Bucket')]
        [ValidateNotNullOrEmpty()]
        [String]$Item,

        # -Validation is used to determine if the file or folder is Present, Absent or Modified
        [Parameter(Mandatory=$true,
                   ParameterSetName='Bucket')]
        [Validation]$BasedUpon,

        # -JAMSCredential is used to specify the JAMS User to login with
        [Parameter(Mandatory=$true,
                   ParameterSetName='Bucket')]
        [ValidateNotNullOrEmpty()]
        $JAMSCredential,

        # -Size can be used to specify the specific file size in KB's needed to satisify the Dependency
        [Parameter(Mandatory=$false,
                   ParameterSetName='Bucket')]
        [int]$Size,

        # -IsFolder can be used to specify that it's a Folder and not a File we're waiting on
        [Parameter(Mandatory=$false,
                   ParameterSetName='Bucket')]
        [Switch]$IsFolder,

        # -Timeout can be used to specify the maximum amount of time to wait
        [Parameter(ParameterSetName='Bucket')]
        [TimeSpan]$Timeout='0.08:00',

        # -Interval can be used to adjust the delay between checking for the File/Folder. The default is 60 seconds.
        [Parameter(ParameterSetName='Bucket')]
        [int]$Interval=60
    )

    Begin
    {
        $Modules = Get-Module

        if ($Modules.Name -contains 'JAMS') {
            Write-Verbose 'JAMS Module already loaded...'
        }
        else {
            Write-Verbose 'Loading the JAMS Module...'

            Import-Module JAMS -ErrorVariable ModError

            foreach ($err in $ModError) {
                Write-Error $err
            }
        }

        Write-Verbose "Connecting to $bucket"
        
        Connect-JS3 -Bucket $Bucket -Name $Bucket -Credential (Get-JAMSCredential $JAMSCredential) | Out-Null

        Write-Verbose "Timeout is set to $timeout"
                
        switch($BasedUpon) 
        {
            'Present'  { Write-Verbose "Waiting on $Item to become Present at $(Get-Date -format 'u') in $Bucket" }
            'Absent'   { Write-Verbose "Waiting on $Item to become Absent at $(Get-Date -format 'u') in $Bucket" }
            'Modified' { Write-Verbose "Waiting on $Item to be Modified at $(Get-Date -format 'u') in $Bucket" }
        }

        $absoluteTimeout = Get-Date 
    }
    Process
    {
        $duration = 0
        $timeoutSeconds = $timeout.TotalSeconds
        $weHaveFiles = $false
        $dateUpdated = $false
        $fileAbsent = $false

        # The user wants to assume the file is there - if it's not, we're going to throw an error.
        if ($BasedUpon –eq [Validation]::Modified) {
            $ModifiedDate = @(Get-JFSChildItem $Item).Modified
            do
            {
                    $checkDate = @(Get-JFSChildItem $Item).Modified
                    
                    Write-Verbose "$Item last Modified: $ModifiedDate"
                    
                    if ($ModifiedDate -ne $checkDate)
                    {
                        Write-Verbose "$Item has been modified..."

                        $dateUpdated = $true
                    }
                    else {
                        if ($duration -gt $timeoutSeconds)
                        {
                            Disconnect-JFS

                            throw 'Timeout while waiting for files'
                        }
                        else {
                            Write-Verbose "$Interval seconds elapsed... Checking again"
                    
                            Start-Sleep -seconds $interval
                    
                            $duration+= $Interval
                        }
                    }
            } while(-not $dateUpdated)
        }
        if ($BasedUpon –eq [Validation]::Present) {
            do 
            {
                $matchedFiles = @(Get-JFSChildItem $Item -ErrorAction SilentlyContinue -ErrorVariable gciError)

                if ($matchedFiles.Count -gt 0)
                {
                    if ($IsFolder) {
                        $checkFolder = $matchedFiles.Substring($var.Length-1)
                        
                        if ($checkFolder -eq '/')
                        {
                            Write-Verbose "$matchedFiles folder found"
                            
                            $weHaveFiles = $true
                        }
                    }
                    else {
                        Write-Verbose "$matchedFiles files found"

                        $weHaveFiles = $true
                    }
                }
                else
                {
                    if ($duration -gt $timeoutSeconds)
                    {
                        Disconnect-JFS

                        throw 'Timeout while waiting for files'
                    }
                    Write-Verbose "$Interval elapsed... Checking again"
                    
                    Start-Sleep -seconds $interval
                    
                    $duration+= $interval
                }
            } while(-not $weHaveFiles)
        }
        if ($BasedUpon –eq [Validation]::Absent) {
            do
            {
                $absentFiles = @(Get-JFSChildItem $Item)

                #
                #  We'll expect $absentFiles to be $null if the file is absent
                #
                if (!$absentFiles)
                    {
                        Write-Verbose "$item is Absent"

                        $fileAbsent = $true
                    }
                    else {
                        if ($duration -gt $timeoutSeconds)
                        {
                            # Is this necessary to have or will the End {} block handle the Disconnect?
                            Disconnect-JFS
                    
                            throw 'Timeout while waiting for files'
                        }
                        Write-Verbose "$Interval elapsed... Checking again"
                    
                        Start-Sleep -seconds $interval
                    
                        $duration+= $interval
                    }
            } while(-not $fileAbsent)
        }
    }
    End
    {
        # Disconnect from Amazon
        Disconnect-JFS
    }
}

<#
.Synopsis
   Submit JAMS Jobs to run on EC2 Instances matching a Tag
.DESCRIPTION
   Used in conjunction with the Connect-JAMSAWSLogin cmdlet to Submit, Schedule or Hold a Job based upon EC2 Instances with a matching Tag
.SYNTAX
   Submit-JAMSJobOnEC2Tag -Tag ActiveMQ -JAMSJob ServiceRelay -RunAs RHRootML -Region 'us-east-1' -StoredCredentials $AWS
.EXAMPLE
   Submit-JAMSJobOnEC2Tag -Tag JAMSDataLD -JAMSJob ReportBatch -RunAs centos -Region 'us-west-2' -StoredCredentials $AWSSession -SubmitHeld -Verbose
#>
function Submit-JAMSJobOnEC2Tag
{
    [CmdletBinding(SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://support.JAMSScheduler.com/',
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Tag')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Tag,
        
        [Parameter(Mandatory=$true,
                   Position=1)]
        [String]
        [ValidateNotNullOrEmpty()]
        $JAMSJob,
  
        [Parameter(Mandatory=$true,
                   Position=2)]
        [ValidateNotNullOrEmpty()]
        [String]
        $RunAs,
        
        [Parameter(Mandatory=$true, 
                   Position=3)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Region,
        
        [Parameter(Mandatory=$false, 
                   Position=4)]
        [Switch]
        $SubmitHeld,
        
        [Parameter(Mandatory=$false, 
                   Position=5)]
        [DateTime]
        $ScheduleFor,
        
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $StoredCredentials
    )
    Begin 
    {
        # Check and see if the AWSPowerShell and JAMS Modules have been loaded
        $Modules = Get-Module

        if (($Modules.Name -contains 'AWSPowerShell') -and ($Modules.Name -contains 'JAMS')) {
            Write-Verbose 'AWSPowerShell and JAMS Modules already loaded...'
        }
        else {
            Write-Verbose 'Loading the AWSPowerShell and JAMS Module...'

            Import-Module AWSPowerShell -WarningAction SilentlyContinue -ErrorVariable +ModError
            Import-Module JAMS -WarningAction SilentlyContinue -ErrorVariable +ModError

            foreach ($err in $ModError) {
                Write-Error $err
            }
        }
    }
    Process
    {
        $Tags = Get-EC2Tag -Credential $StoredCredentials -Region $Region
        
        if ($Tags.Value -notcontains $Tag) 
        {
            Write-Verbose "No instance found with $Tag"
        }
        else {
            foreach ($inst in $Tags) 
            {
                if (($inst.Value -contains $Match) -and ($inst.ResourceType -eq 'instance')) 
                {   
                    # Run the Job immediately
                    if ((!$SubmitHeld) -and (!$ScheduleFor)) 
                    {
                        Write-Verbose "Submitting $JAMSJob to run"
                        
                        Submit-JAMSEntry -Name $JAMSJob -Agent $Status.Instances.PublicIpAddress -UserName $RunAs | Out-Null
                    }
                    
                    # Hold the Job until released
                    if ($SubmitHeld) 
                    {
                        Write-Verbose "Holding $JAMSJob"
                        
                        Submit-JAMSEntry -Name $JAMSJob -Agent $Status.Instances.PublicIpAddress -UserName $RunAs -Hold | Out-Null                        
                    }
                    
                    # Schedule this to run later
                    if ($ScheduleFor) 
                    {
                        Write-Verbose "Scheduling $JAMSJob for $ScheduleFor"
                        
                        Submit-JAMSEntry -Name $JAMSJob -Agent $Status.Instances.PublicIpAddress -UserName $RunAs -After $ScheduleFor | Out-Null                        
                    }                 
                }
            }
        }
    }
    End
    {
    }
}