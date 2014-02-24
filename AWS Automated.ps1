#
# Amazon EC2 Stored Credentials
#
$secretKey = (Get-JAMSCredential AmazonEC2).GetCredential($null,$null)
$accessKey = (Get-JAMSCredential AmazonEC2).UserName

$creds = New-AWSCredentials -AccessKey $accessKey -SecretKey $secretKey.password

#
# Cache our credentials for use by AWS.NET API
#
Set-AWSCredentials -Credentials $creds -StoreAs AmazonAWSPS

$storedCred = "AmazonAWSPS"

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
Import-Csv C:\Amazon\Instances.csv |`
    ForEach-Object {
        $InstanceTable.Add(("{0}|{1}" -f $_.Instance,$_.Region), "OFF")
        #$Instance += $_.Instance
        #$Region += $_.Region
}

#
# How many instances did we pull in?
#
Write-Output $InstanceTable.Count

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

    Write-Output $instanceName
    Write-Output $regionName
    
    # Get the instance
    $InstanceTable[$key] = Get-EC2InstanceStatus -InstanceIds $instanceName -StoredCredentials "$storedCred" -Region $regionName
}

#$InstanceTable.Count

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
        Write-Output "$instanceName is running."

        #
        # Instance is already running, let's make sure we have the right IP and update our queue for it
        #
        $publicIP += Get-EC2Instance -Instance $instanceName -StoredCredentials "$storedCred" -Region $regionName
    }
    if ($state -eq $null)
    {
        Write-Output "$instanceName is not running."
        Start-EC2Instance -InstanceIds $instanceName -StoredCredentials "$storedCred" -Region $regionName

        #
        # Sleep for 5 seconds to give that instance enough time to get an IP
        #
        Start-Sleep 5

        $publicIP += Get-EC2Instance -Instance $instanceName -StoredCredentials "$storedCred" -Region $regionName
    }
}

#
# Does our batch queue exist?
#
if (!(Test-Path JD:\Queues\AmazonAWS)) {
    $Queue = New-Item JD:\Queues\AmazonAWS
}
else {
    $Queue = Get-ChildItem JD:\Queues\AmazonAWS
}
#
# Update our Batch Queue - we will iterate through our array of IP's to update each
#
$publicIP.Instances.Count

$Queue.StartedOn.Clear()
foreach($IP in $publicIP)
{
    $queueIP = $IP.Instances.PublicIpAddress
    $Queue.StartedOn.Add("$queueIP")
}
$Queue.JobLimit = 500
$Queue.Update()