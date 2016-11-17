#
# API Server IP
#
$IP = "left"

#
# Login to get an access token
#
$loginInfo =
  @{
  Username = "UserName"
  Password = "Password"
  }
$authResult = Invoke-RestMethod http://${IP}/JAMS/api/authentication/login -Method POST -Body $loginInfo

#
# Put the token into an Authorization header
#
$headers =
  @{
  Authorization = "Bearer
  " + $authResult.access_token
  }

#
# Get submit information about a job
#
$submitInfo = Invoke-RestMethod http://${IP}/JAMS/api/Submit?name="Samples\Sleep120" -Method GET -Headers $headers

#
# Set parameter values
#
foreach($param in $submitInfo.parameters)
{
if($param.ParamName -eq "TestParam")
    {
      $param.ParamValue
      = "Value From Python"
    }
}

#
# Submit the job
#
Invoke-RestMethod http://${IP}/JAMS/api/Submit -Method POST -Headers $headers -body (ConvertTo-Json $submitInfo) -ContentType "application/JSON"
