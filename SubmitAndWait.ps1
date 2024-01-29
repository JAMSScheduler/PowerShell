Import-Module JAMS
## Change localhost in below line to be JAMS Server name, if not running on scheduler.
$JAMSServer = "localhost"
New-PSDrive JD JAMS $JAMSServer -ErrorAction SilentlyContinue

## Change path in line below to point to the job that should be submitted
$SubmitJob = Get-Item JD:\Samples\SleepJob 

$submission = Submit-JAMSEntry -InputJob $SubmitJob -Server $JAMSServer  ## See comment on line 2. Same applies here to server

#Need a small buffer to safely check the executing status of the job
start-sleep 1

$entry = Get-JAMSEntry -Entry $submission.JAMSEntry -Server $JAMSServer

If ($entry.CurrentState -eq [MVPSI.JAMS.EntryState]::Executing ){
    # Wait for the job to complete
    Wait-JAMSEntry -Name $entry.JAMSEntry -State Executing -Server $JAMSServer
    }
# Get updated information about the submitted job
$entry = Get-JAMSEntry -Entry $submission.JAMSEntry -Server $JAMSServer

write-host $entry.FinalStatusCode


# The $entry.FinalStatusCode value will have the return code from the job.  Generally speaking, 0 is good, and anything else is considered a failure in JAMS by default.  
