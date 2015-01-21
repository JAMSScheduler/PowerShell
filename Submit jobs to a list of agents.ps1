# Import the JAMS module
Import-Module JAMS
# Define the job you want to submit, use the full path to the job
$jobName = "\Sleep120"
#
# Read a file which contains a list of Agents
#
$agentList = Get-Content C:\Temp\AgentList.txt
#
# Initialize an array to hold all of the jobs that we are about to submit
#
$processEntries = @()
#
# Submit a job for each of the things in the file
#
foreach($agent in $agentList)
{
    #
    # Submit Each job using Submit-JAMSEntry to each agent in the list
    #
    $submitResult = Submit-JAMSEntry $jobName -Agent $agent -Verbose
    #
    # Add the JAMSEntry number to the array
    #
    $processEntries += $submitResult.JAMSEntry
}
#
# Wait for all of the jobs we submitted to complete
#
Wait-JAMSEntry $processEntries -verbose
#
# Now, check the status of each entry
#
foreach($entry in $processEntries)
{
    $entryInfo = Get-JAMSEntry -Entry $entry
    write-host "Final status of entry " $entryInfo.JAMSEntry "is" $entryInfo.FinalStatus
}
