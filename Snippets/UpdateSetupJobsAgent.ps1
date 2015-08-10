# Define JAMS Drive
New-PSDrive JD JAMS YourJAMSServerName

# Define an array to hold the collection
$Setup = @()

# Get the Setup
$Setup = Get-ChildItem JD:\Test\TestSetup

# Hash the number of steps
$Steps = $Setup.Jobs

# Loop through to change the nodes
foreach ($Step in $Steps) {
    $Step.AgentNode = "MVPCT0"
}
$Setup.Update()
