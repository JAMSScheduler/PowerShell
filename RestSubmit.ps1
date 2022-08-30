#
# This script makes a REST API call to JAMS which will update the value of a property in the submitInfo, then submit the changed job.
#

#The target server to be used in the URI e.g. 'google' in http://www.google.com/
$restServer = ""

#login information for authentication against the rest server, in this case we're targeting JAMS, so this is a user which can authenticate with the JAMS REST API
$loginInfo = @{
    Username = ""
    Password = ""}

#issuing a rest call to JAMS attempting to authenticate with our login info. This should return a token to be used for further authentication
$authResult = Invoke-RestMethod "http://$restServer/JAMS/api/authentication/login" -Method POST -Body $loginInfo

#this builds the authorization header to be used in our various REST actions 
$headers = @{
    Authorization = "Bearer " + $authResult.access_token}

#Qualified path of the job source we're trying to submit
$qualifiedJobPath = "\CustomJobs\RESTAPIJob"

#Building the target URI we're going to invoke for getting the submit info
$submitInfoURI = ("http://" + $restServer + "/jams/api/submit?name="+$qualifiedJobPath)

#Invoke the method and store the resulting JSON in a PowerShell object
$submitInfo = Invoke-RestMethod -Uri $submitInfoURI -Method GET -Headers $headers -ContentType "application/json" -Verbose

#Building the target URI we're going to invoke to submit the entry
$submitURI = ("http://" + $restServer + "/jams/api/submit/")

#Submit the updated submitInfo

$submitResults = Invoke-RestMethod -Uri $submitURI -Method POST -Headers $headers -Body (ConvertTo-JSON $submitinfo -Depth 10) -ContentType "application/JSON" -Verbose
