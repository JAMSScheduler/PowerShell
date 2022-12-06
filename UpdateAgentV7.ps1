#
#  Create a PSDrive that points to the JAMS Server you want to use
#  You could do this outside of the script 
#
Import-Module JAMS
New-PSDrive JD JAMS localhost

#
#  Get a collection of jobs that we want to update
#  Modify the path below to target a specific folder in your JAMS environment.
#   - The option -Recurse may be added to below line, but depending on system resources, 
#   - and the number of jobs in the folder/subfolders, may work unreliably.  
#	- Targeting a specific folder is recommended, or folders can be looped through.  Contact your account rep for Professional Services help to make enhancements.
#
$jobs = get-childitem JD:\TestJobs\ -ObjectType job -FullObject -IgnorePredefined

#
#  Iterate through the loop and update each job
#
foreach ($j in $jobs)
{
	#
	# Modify the "TestingNewVM" value to be the name of the existing agent reference
	#
    if($j.AgentName -match "TestingNewVM"){
    
        write-host "Updating Job - " $j.Name
		# Modify the "NewAgent" value to be the name of the agent you would like the jobs to reference after completion.
        $j.AgentName = "NewAgent"
        $j.Update()
        
    }
}
Remove-PSDrive
