Import-Module JAMS

##
# Adjust below path to create job in desired folder (Samples) on desired Scheduler (Localhost)
##
$job = new-item -Path "JAMS::Localhost\Samples" -Name "NewSampleCreation" -ItemType "Job" -MethodName "PowerShell"
$job.Description = "Created from PowerShell" 
$job.Source = @'
Start-Sleep 10
'@

$elem = new-object -Typename MVPSI.JAMS.JobDependency
$elem.DependOnJobName = "\Samples\SleepJob"
$job.elements.add($elem)
$job.Update()