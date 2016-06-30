#
# API Server IP
#
$IP = "52.35.171.187"

#
#  Login to get an access token
#
$loginInfo = @{
    Username = "Username"
    Password = "Password"
}
$authResult = Invoke-RestMethod http://${IP}/JAMS/api/authentication/login -Method POST -Body $loginInfo

#
#  Put the token into an Authorization header
#
$headers = @{
    Authorization = "Bearer " + $authResult.access_token
}

#Users
$Users = Invoke-RestMethod http://${IP}/JAMS/api/UserSecurity/Test -Method GET -Headers $headers
$Users | Out-Default

#
#  Call REST APIs until the token expires (12 hours by default)
#
$Queues = Invoke-RestMethod http://${IP}/JAMS/api/BatchQueue -Method GET -Headers $headers
$Queues | Out-Default

Invoke-RestMethod http://${IP}/JAMS/api/date/evaluate/"first workday of next month" -Method GET -Headers $headers | out-default
