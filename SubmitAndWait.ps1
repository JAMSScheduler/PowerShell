Import-Module JAMS
## Change localhost in below line to be JAMS Server name, if not running on scheduler.
New-PSDrive JD JAMS localhost -ErrorAction SilentlyContinue

## Change path in line below to point to the job that should be submitted
$SubmitJob = Get-Item JD:\Samples\Sleep60 

$submission = Submit-JAMSEntry -InputJob $SubmitJob -Server localhost  ## See comment on line 2. Same applies here to server

#Need a small buffer to safely check the executing status of the job
start-sleep 1

$entry = Get-JAMSEntry -Entry $submission.JAMSEntry 

If ($entry.CurrentState -eq [MVPSI.JAMS.EntryState]::Executing ){
    # Wait for the job to complete
    Wait-JAMSEntry -Name $entry.Name -State Executing
    }
# Get updated information about the submitted job
$entry = Get-JAMSEntry -Entry $submission.JAMSEntry 

write-host $entry.FinalStatusCode


# The $entry.FinalStatusCode value will have the return code from the job.  Generally speaking, 0 is good, and anything else is considered a failure in JAMS by default.  
