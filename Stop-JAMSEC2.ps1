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