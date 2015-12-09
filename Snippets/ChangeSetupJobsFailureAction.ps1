### This is a Powershell script to take one setup, iterate through each setup job to change the Setup Failure Action for each setup job to Fail

### Import the JAMS module
Import-Module JAMS

### Define the JAMS server
$DefaultJAMSServer = "JAMSServerName"

### Create the JAMS Drive
New-PSDrive JD JAMS

### Define the path to the setup to use
$setupPath = "\Audit\TestSetup"

#
# Get The Setup
#
$mySetup = Get-ChildItem JD:$setupPath

#
# Get the Setup Job(s) from the Setup
#
$jobs = $mySetup.Jobs 

#
# Use Foreach as we may have more than 1 Job
#
foreach($sJob in $jobs)
{
    #
    # Update the Setting
    #
    $sJob.FailureAction = "Fail"
}

#
# Save the Settings on the Setup
#
$mySetup.Update()
