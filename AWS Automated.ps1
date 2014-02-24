#
# Amazon EC2 Stored Credentials
#
$secretKey = (Get-JAMSCredential AmazonEC2).GetCredential($null,$null)

$creds = New-AWSCredentials -AccessKey AKIAJB6SQOMBRYNOLIGA -SecretKey $secretKey.password
Set-AWSCredentials -Credentials $creds -StoreAs DevonL

$storedCred = "DevonL"

#
# Define our arrays
#
$Instance = @()
$Region = @()
$Ainfo = @()
$publicIP = @()
$keys = @()

# Hash table for instances
$InstanceTable = @{}

#
# Import and parse the CSV file
#
Import-Csv C:\Amazon\Instances.csv |`
    ForEach-Object {
        $InstanceTable.Add(("{0}|{1}" -f $_.Instance,$_.Region), "OFF")
        #$Instance += $_.Instance
        #$Region += $_.Region
}

#
# Check the Status of each instance
#
Write-Output $InstanceTable.Count

foreach($val in $InstanceTable.Keys)
{
    $keys += $val
}

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
    }
    if ($state -eq $null)
    {
        Write-Output "$instanceName is not running."
        Start-EC2Instance -InstanceIds $instanceName -StoredCredentials "$storedCred" -Region $regionName

        Start-Sleep 5

        $publicIP += Get-EC2Instance -Instance $instanceName -StoredCredentials "$storedCred" -Region $regionName
    }
}

#
# Update our Batch Queue
#

$publicIP.Instances.Count

$Queue = New-Item JD:\Queues\testQueue
$Queue.StartedOn.Clear() 
foreach($IP in $publicIP)
{
    $queueIP = $IP.Instances.PublicIpAddress
    $Queue.StartedOn.Add("$queueIP")
}
$Queue.JobLimit = 500
$Queue.Update()