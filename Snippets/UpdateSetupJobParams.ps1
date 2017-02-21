# This snippet is utilized to update specific Parameters within setup Jobs
# Lines 8-10 will need to be modified to hold the correct values
# and the if/else-if logic on lines 30 onwards will need to be updated for 
# your own environment as well.

# Import the PowerShell Module and create a PS Drive for JAMS
Import-Module JAMS
$null = New-PSDrive JD JAMS localhost

# The new values for each of our 4 Parameters (ServerName, DB, Batch and ConnectionString)
$ServerNameValue = ""
$DBValue = ""
$BatchValue = ""
$ConnectionSValue = ""

# Get a collection of all of the Setups in a given Branch Folder
$Setups = Get-ChildItem JD:\MySetups\* -ObjectType setup

# A series of loops, first we'll loop through the Setups
foreach ($Setup in $Setups) {
    $Steps = $Setup.Jobs

    # Next loop is for the Setup Jobs (Steps)
    foreach ($s in $Steps) {
        $Param = $S.Parameters

        # Next we'll loop through each Parameter
        foreach ($p in $Param) {
            # Here we'll match the Param Name to update each with the corresponding value
            if ($P.ParamName -eq "ServerName") {
                $P.DefaultValue = $ServerNameValue
                $S.Update()
            }
            elseif ($P.ParamName -eq "DB") {
                $P.DefaultValue = $DBValue
                $S.Update()
            }
            elseif ($P.ParamName -eq "Batch") {
                $P.DefaultValue = $BatchValue
                $S.Update()
            }
            elseif ($P.ParamName -eq "ConnectionString") {
                $P.DefaultValue = $ConnectionSValue
                $S.Update()
            }
        }
    }
    # Update the Setups
    $Setup.Update()
}
