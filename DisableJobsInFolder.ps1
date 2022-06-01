#
#  Create a PSDrive that points to the JAMS Server you want to use
#  You could do this outside of the script 
#
Import-Module JAMS
New-PSDrive JD JAMS localhost
#
#  Get a collection of jobs that we want to update
#
$jobs = get-childitem JD:\Samples -ObjectType job -FullObject -Recurse -IgnorePredefined
#
#  Iterate through the loop and update each job
#
foreach ($j in $jobs)
{
        write-host "Updating Job - " $j.Name
        $j.Properties.SetValue("Enabled", $false)
        $j.Update()
}