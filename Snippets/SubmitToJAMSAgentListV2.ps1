Import-Module JAMS
#
#  Gather a list of Agents on the JAMS server, filtered by Platform (i.e. Windows, Linux, etc.).
#
$agents = [MVPSI.JAMS.Agent]::Find("*","$JamsDefaultServer")| ? { $_.Platform -eq "<<Platform>>" }
$listofagents = $agents.AgentName
#
#  Initialize an array to hold all of the jobs that we are about to submit
#
$processEntries = @()
#
#  Submit a job for each of the things in the file
#
foreach($agent in $listofagents)
{
    #
    #  The job that we submit (ProcessId) has a parameter named "id" which matches the
    #  $id PowerShell variable, we submit with the -UseVariables parameter to make
    #  that match
    #
    #id = "$idObj"
    $submitResult = Submit-JAMSEntry -Name "<<Job>>" -Agent $agent
                #
    #  Add the JAMSEntry number to the array
    #
    $processEntries += $submitResult.JAMSEntry
}
#
#  Wait for all of the jobs we submitted to complete
#
Wait-JAMSEntry $processEntries -verbose
#
#  Now, check the status of each entry
#
foreach($entry in $processEntries)
{
    $entryInfo = Get-JAMSEntry -Entry $entry
    write-host "Final status of entry " $entryInfo.JAMSEntry "is" $entryInfo.FinalStatus
}
