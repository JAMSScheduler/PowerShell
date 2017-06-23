Import-Module JAMS

# Set JAMS REST API Endpoint
$api="http://localhost/jams/api/"

# Retrieve Authorization Token
$User = "user"
$jamsUser = (Get-JAMSCredential $User -Server "localhost" ).GetCredential($null,$null)
$password = $jamsUser.password

$loginInfo = @{
    Username = "$User"
    Password = "$password"
    }
$authResult = Invoke-RestMethod $api/authentication/login -Method POST -Body $loginInfo

$headers = @{
    Authorization = "Bearer " + $authResult.access_token
    }


# AGENT
$agentid="12"
$agentname="Existing Agent"
#
# Get List Of Agents
Invoke-RestMethod -Uri $api/agent -Method GET -Headers $headers
#
# Get Agent With Specified ID
Invoke-RestMethod -Uri $api/agent/$agentid -Method GET -Headers $headers
#
# Get Agent With Specified Name
Invoke-RestMethod -Uri $api/agent/$agentname -Method GET -Headers $headers
#
# Update Agent With Specified Name
$agent=Invoke-RestMethod -Uri $api/agent/$agentname -Method GET -Headers $headers
$agent.description="Update 2"
Invoke-RestMethod -Uri $api/agent -Method PUT -Headers $headers -Body (ConvertTo-Json $agent) -ContentType "application/JSON"
#
# Create Agent Based On Template Agent With Specified Name
$agent=Invoke-RestMethod -Uri $api/agent/$agentname -Method GET -Headers $headers
$agent.agentName="New Agent"
Invoke-RestMethod -Uri $api/agent -Method POST -Headers $headers -Body (ConvertTo-Json $agent) -ContentType "application/JSON"
#
# Create Agent
Invoke-RestMethod -Uri $api/agent -Method POST -Headers $headers -Body (ConvertTo-Json @{"agentName" = "New Agent"; "description" = "New Agent Description"; "platform" = "Unix"; "username" = "JAMS"}) -ContentType "application/JSON"
#
# Delete Agent With Specified Name
Invoke-RestMethod -Uri $api/agent/$agentname -Method DELETE -Headers $headers


# BATCHQUEUE
$batchqueueid="2"
$batchqueuename="BatchQueue003"
#
# List All Batch Queues
Invoke-RestMethod -Uri $api/batchqueue -Method GET -Headers $headers
#
# Get The Batch Queue With Specified ID
Invoke-RestMethod -Uri $api/batchqueue/$batchqueueid -Method GET -Headers $headers
#
# Get The Batch Queue With Specified Name
Invoke-RestMethod -Uri $api/batchqueue/$batchqueuename -Method GET -Headers $headers
#
# Create Batch Queue Based On Template With Specified Name
$batchqueue=Invoke-RestMethod -Uri $api/batchqueue/$batchqueuename -Method GET -Headers $headers
$batchqueue.queueName="New BatchQueue"
Invoke-RestMethod -Uri $api/batchqueue -Method POST -Headers $headers -Body (ConvertTo-Json $batchqueue) -ContentType "application/JSON"
#
# Update Batch Queue With Specified Name
$batchqueue=Invoke-RestMethod -Uri $api/batchqueue/$batchqueuename -Method GET -Headers $headers
$batchqueue.description="Updated 2"
$batchqueue.startedOn=@(@{nodeName='10.0.0.1'}, @{nodeName='10.0.0.2'})
Invoke-RestMethod -Uri $api/batchqueue -Method PUT -Headers $headers -Body (ConvertTo-Json $batchqueue) -ContentType "application/JSON"
#
# Start Batch Queue With Specified Name
Invoke-RestMethod -Uri $api/batchqueue/start/$batchqueuename -Method POST -Headers $headers
#
# Stop Batch Queue With Specified Name
Invoke-RestMethod -Uri $api/batchqueue/stop/$batchqueuename -Method POST -Headers $headers


# ENTRY
$jamsEntry="276"
#
# Get List Of Entries In Current Schedule
Invoke-RestMethod -Uri $api/entry -Method GET -Headers $headers
#
# Get Entry in Current Schedule With Specified jamsEntry
Invoke-RestMethod -Uri $api/entry/$jamsEntry -Method GET -Headers $headers
#
# Hold Entry in Current Schedule With Specified jamsEntry
$entry=Invoke-RestMethod -Uri $api/entry/$jamsEntry -Method GET -Headers $headers
Invoke-RestMethod -Uri $api/entry/$jamsEntry/hold -Method PUT -Headers $headers -Body (ConvertTo-Json $entry) -ContentType "application/JSON"
#
# Release Entry in Current Schedule With Specified jamsEntry
$releaseparams=@{"auditComment"="Released by REST"; "releaseType"="1"; "forcedPresent"="true"; "dependOK"="true"}
$entry=Invoke-RestMethod -Uri $api/entry/$jamsEntry/release -Method PUT -Headers $headers -Body (ConvertTo-Json $releaseparams) -ContentType "application/JSON"
#
# Cancel Entry in Current Schedule With Specified jamsEntry
$entry=Invoke-RestMethod -Uri $api/entry/$jamsEntry -Method GET -Headers $headers
Invoke-RestMethod -Uri $api/entry/$jamsEntry/cancel -Method PUT -Headers $headers -Body (ConvertTo-Json $entry) -ContentType "application/JSON"
#
# Get Parameter List For Entry in Current Schedule With Specified jamsEntry
Invoke-RestMethod -Uri $api/entry/$jamsEntry/parameter -Method GET -Headers $headers
#
# Get Specified Parameter For Entry in Current Schedule With Specified jamsEntry
Invoke-RestMethod -Uri $api/entry/$jamsEntry/parameter/Param002 -Method GET -Headers $headers


# HISTORY
$jobname="JobStep1"
$ron="1302"
#
# Get History
Invoke-RestMethod -Uri $api/history -Method GET -Headers $headers
#
# Get Log File For Specified Job
Invoke-RestMethod -Uri $api/history/job/log/$jobname/$ron/0 -Method GET -Headers $headers


# JOB
$jobname="job001"
$jobid="102"
$path="Demo"
$folderid="10"
#
# Get List Of Jobs
Invoke-RestMethod -Uri $api/job -Method GET -Headers $headers
#
# Get Job With Specified Name
Invoke-RestMethod -Uri $api/job/$jobname -Method GET -Headers $headers
#
# Get Job With Specified ID
Invoke-RestMethod -Uri $api/job/$jobid -Method GET -Headers $headers
#
# Get Jobs In Specified Folder Name
Invoke-RestMethod -Uri $api/job/folder/$path -Method GET -Headers $headers
#
# Get Jobs In Specified Folder ID
Invoke-RestMethod -Uri $api/job/folder/$folderid -Method GET -Headers $headers
#
# Update Job with Specified ID
$job=Invoke-RestMethod -Uri $api/job/$jobid -Method GET -Headers $headers
$job.Description="Update"
Invoke-RestMethod -Uri $api/job -Method PUT -Headers $headers -Body (ConvertTo-Json $job) -ContentType "application/JSON"
#
# Create Job with Specified Name Based On Template Job
$job=Invoke-RestMethod -Uri $api/job/$jobid -Method GET -Headers $headers
$job.jobName="job005"
Invoke-RestMethod -Uri $api/job -Method POST -Headers $headers -Body (ConvertTo-Json $job) -ContentType "application/JSON"
#
# Delete Job with Specified Name
Invoke-RestMethod -Uri $api/job?name=\$path\$jobname -Method DELETE -Headers $headers


# SUBMIT
$jobname="Job010"
$submitid="123"
$jobid="102"
#
# Get Submitinfo For Job With Specified Name
Invoke-RestMethod -Uri $api/submit?name=$jobname -Method GET -Headers $headers
#
# Get Submitinfo For Job With Specified ID
Invoke-RestMethod -Uri $api/submit/job/$jobid -Method GET -Headers $headers
#
# Submit Submitinfo With Specified Name
Invoke-RestMethod -Uri $api/submit -Method POST -Headers $headers -Body (ConvertTo-Json @{"name" = $jobname}) -ContentType "application/JSON"
#
# Submit Submitinfo With Specified Object
$submitinfo=Invoke-RestMethod -Uri $api/submit?name=$jobname -Method GET -Headers $headers
Invoke-RestMethod -Uri $api/submit -Method POST -Headers $headers -Body (ConvertTo-Json $submitinfo) -ContentType "application/JSON"
#
# Submit Modified Submitinfo
$submitinfo=Invoke-RestMethod -Uri $api/submit?name=$jobname -Method GET -Headers $headers
$submitinfo.overrideName="New Job Name"
$submitinfo.userName="JAMS"
$submitinfo.afterTimeUTC="2017-06-24T22:40:00.0000000Z"
Invoke-RestMethod -Uri $api/submit -Method POST -Headers $headers -Body (ConvertTo-Json $submitinfo) -ContentType "application/JSON"


# TRIGGER
$triggername="Trigger010"
$folderid="15"
$path="Demo"
#
# Get Trigger With Specified Name
Invoke-RestMethod -Uri $api/trigger/$triggername -Method GET -Headers $headers
#
# List All Triggers In Specified Folder ID
Invoke-RestMethod -Uri $api/trigger/Folder/$folderid -Method GET -Headers $headers
#
# Create Trigger With Specified Name Based On Template Trigger
$trigger=Invoke-RestMethod -Uri $api/trigger/$triggername -Method GET -Headers $headers
$trigger.triggerName="Trigger011"
Invoke-RestMethod -Uri $api/trigger -Method POST -Headers $headers -Body (ConvertTo-Json $trigger) -ContentType "application/JSON"
#
# Update Trigger with Specified Name
$trigger=Invoke-RestMethod -Uri $api/trigger/$triggername -Method GET -Headers $headers
$trigger.description="Updated"
Invoke-RestMethod -Uri $api/trigger -Method PUT -Headers $headers -Body (ConvertTo-Json $trigger) -ContentType "application/JSON"
#
# Reset Trigger with Specified Name
Invoke-RestMethod -Uri $api/trigger/reset?name=$triggername -Method POST -Headers $headers
#
# Disable Trigger with Specified Name
Invoke-RestMethod -Uri $api/trigger/disable?name=$triggername -Method POST -Headers $headers
#
# Enable Trigger with Specified Name
Invoke-RestMethod -Uri $api/trigger/enable?name=$triggername -Method POST -Headers $headers
#
# Delete Trigger with Specified Name
Invoke-RestMethod -Uri $api/trigger?name=\$path\$triggername -Method DELETE -Headers $headers
