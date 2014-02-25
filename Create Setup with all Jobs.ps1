#
# This code example is intended to create a Setup in JAMS with all of the jobs
# Contained in our "Samples Folder." 
# It will define each step as 1, 2, 3, etc
#


#
# Get the Setup
#
$Setup = New-Item \Samples\MyNewSetup -ItemType 'Setup'

#
# Get the Jobs we want to add as SetupJobs
#
$Jobs = Get-ChildItem -ObjectType Job JD:\Samples\*
$x = 1

#
# Add the Jobs as SetupJobs to the Setup
#
ForEach($job in $jobs)
{
    $Sj = New-Object "MVPSI.JAMS.SetupJob"
    $Sj.JobName = $Job.QualifiedName
    $Sj.Step = $x++
    $Setup.Jobs.Add($Sj)
}

#
# Save the Setup
#
$Setup.Update()