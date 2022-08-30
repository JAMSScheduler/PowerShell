#
# This script makes a REST API call to JAMS and gets all the entries in the monitor, it then cancels/deletes particular entries by name
#

#The target server to be used in the URI e.g. 'google' in http://www.google.com/
$restServer = ""

#login information for authentication against the rest server, in this case we're targeting JAMS, so this is a user which can authenticate with the JAMS REST API
$loginInfo = @{
    Username = ""
    Password = ""
    }

#URI for generating an authentication token
$AuthURI = ("http://" + $restServer + "/JAMS/api/authentication/login")

#issuing a rest call to JAMS attempting to authenticate with our login info. This should return a token to be used for further authentication
$authResult = Invoke-RestMethod $AuthURI -Method POST -Body $loginInfo -Verbose

#this builds the authorization header to be used in our various REST actions 
$headers = @{
    Authorization = "Bearer " + $authResult.access_token}

#Building the target URI we're going to invoke
$EntryURI = ("http://" + $restServer + "/jams/api/entry")

#Invoke the method and store the resulting JSON in a PowerShell object
$getResults = Invoke-RestMethod -Uri $EntryURI -Method GET -Headers $headers -ContentType "application/json" -Verbose

# do some processing on our results
# Add a list of entries in the results table and output the entries
$resultTable = @()
foreach($job in $getResults){
    $out = New-Object psobject
    $out | Add-Member noteproperty "Entry" $($job.jamsEntry)
    $out | Add-Member noteproperty "JobName" $($job.jobName)
    $out | Add-Member noteproperty "ScheduledTime" $(([dateTime]$job.scheduledTimeUTC).ToLocalTime())
    $out | Add-Member noteproperty "CurrentStatus" $($job.currentState)
    $out | Add-Member noteproperty "FinalSeverity" $($job.finalSeverity)
    $resultTable += $out
}
$resultTable | Sort-Object -Property "ScheduledTime" | Format-Table -AutoSize | Out-Host