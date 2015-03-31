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
Function Start-JAMSEC2($InputFile, $QueueName, $JobLimit, $StoredCredentials) {
    if ($InputFile -eq $null) {
        Write-Error "-InputFile is a required value"
    }
    if ($QueueName -eq $null) {
        Write-Error "-QueueName is a required value"
    }
    if ($JobLimit -eq $null) {
        Write-Error "-JobLimit is a required value"
    }
    if ($JobLimit -isnot [int]) {
        Write-Error "-JobLimit requires integer value"
    }
    else {
        #
        # Define our arrays
        #
        $Instance = @()
        $Region = @()
        $Ainfo = @()
        $publicIP = @()
        $keys = @()

        #
        # Hash table for instance names
        #
        $InstanceTable = @{}

        #
        # Import and parse the CSV file of our instances and regions
        #
        Import-Csv $InputFile |`
        ForEach-Object {
            $InstanceTable.Add(("{0}|{1}" -f $_.Instance,$_.Region), "OFF")
        }

        #
        # How many instances did we pull in?
        #
        Write-Verbose $InstanceTable.Count

        foreach($val in $InstanceTable.Keys)
        {
            $keys += $val
        }

        #
        # Iterate through our hash table and determine the status of each EC2 instance
        #
        foreach($key in $keys)
        {
            $keyName = $key.Split('|')
            $instanceName = $keyName[0]
            $regionName = $keyName[1]

            Write-Verbose $instanceName
            Write-Verbose $regionName
    
            # Get the instance
            $InstanceTable[$key] = Get-EC2InstanceStatus -InstanceIds $instanceName -Credentials $StoredCredentials -Region $regionName
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

            if ($state -eq "running")
            {
                Write-Verbose "$instanceName is running."

                #
                # Instance is already running, let's make sure we have the right IP and update our queue for it
                #
                $publicIP += Get-EC2Instance -Instance $instanceName -Credentials $StoredCredentials -Region $regionName
            }
            if ($state -eq $null)
            {
                Write-Verbose "$instanceName is not running."
                Start-EC2Instance -InstanceIds $instanceName -Credentials $StoredCredentials -Region $regionName

                #
                # Sleep for 5 seconds to give that instance enough time to get an IP
                #
                Write-Verbose "Sleeping for 5 seconds to get IP."
                Start-Sleep 5

                $publicIP += Get-EC2Instance -Instance $instanceName -Credentials $StoredCredentials -Region $regionName
            }
        }

        #
        # Does our batch queue exist?
        #
        if (!(Test-Path JD:\Queues\$QueueName)) {
            $Queue = New-Item JD:\Queues\$QueueName
        }
        else {
            $Queue = Get-ChildItem JD:\Queues\$QueueName
        }
        #
        # Update our Batch Queue - we will iterate through our array of IP's to update each
        #
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
Function Stop-JAMSEC2($InputFile, $StoredCredentials) {
    if ($InputFile -eq $null) {
        Write-Error "-InputFile is a required value"
    }
    if ($StoredCredentials -eq $null) {
        Write-Error "-StoredCredentials is a required value"
    }
    else {
        #
        # Define our arrays
        #
        $Instance = @()
        $Region = @()
        $keys = @()

        #
        # Hash table for instance names
        #
        $InstanceTable = @{}

        #
        # Import and parse the CSV file of our instances and regions
        #
        Import-Csv $InputFile |`
        ForEach-Object {
            $InstanceTable.Add(("{0}|{1}" -f $_.Instance,$_.Region), "OFF")
        }

        #
        # How many instances did we pull in?
        #
        Write-Verbose $InstanceTable.Count

        foreach($val in $InstanceTable.Keys)
        {
            $keys += $val
        }

        #
        # Iterate through our hash table and determine the status of each EC2 instance
        #
        foreach($key in $keys)
        {
            $keyName = $key.Split('|')
            $instanceName = $keyName[0]
            $regionName = $keyName[1]

            Write-Verbose $instanceName
            Write-Verbose $regionName
    
            # Get the instance
            $InstanceTable[$key] = Get-EC2InstanceStatus -InstanceIds $instanceName -Credentials $StoredCredentials -Region $regionName
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

            if ($state -eq "running")
            {
                Write-Verbose "$instanceName is running."

                #
                # Instance is running, stop the EC2 instance
                #
                Stop-EC2Instance -Instance $instanceName -Credentials $StoredCredentials -Region $regionName
            }
            if ($state -eq $null)
            {
                Write-Verbose "$instanceName is not running."
            }
        }
    }
}

<#
.Synopsis
   Connect to your instance of Amazon AWS
.DESCRIPTION
   Connect and store an Amazon AWS Session into a PowerShell variable utilizing a stored JAMS User
.SYNTAX
   Connect-JAMSAWSLogin -JAMSCred AmazonAWSLogin -SessionName AmazonAWS
.EXAMPLE
   $AmazonAWS = Connect-JAMSAWSLogin -JAMSCred AmazonAWSLogin -SessionName AmazonAWS
#>
Function Connect-JAMSAWSLogin($JAMSCred, $SessionName) {
     if ($JAMSCred -eq $null) {
        Write-Error "-JAMSCred is a required value"
    }
    if ($SessionName -eq $null) {
        Write-Error "-SessionName is a required value"
    }
    else {
        #
        # Amazon EC2 Stored Credentials
        #
        $secretKey = (Get-JAMSCredential $JAMSCred).GetCredential($null,$null)
        $accessKey = (Get-JAMSCredential $JAMSCred).UserName

        $creds = New-AWSCredentials -AccessKey $accessKey -SecretKey $secretKey.password

        #
        # Cache our credentials for use by AWS.NET API
        #
        Set-AWSCredentials -Credentials $creds -StoreAs $SessionName

        $storedCred = $SessionName
        
        return $creds

    }
}