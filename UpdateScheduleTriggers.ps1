Import-Module JAMS

#Adjust path below to target specific folder
$jobs = Get-ChildItem JAMS::localhost\Samples -ObjectType job -FullObject

foreach($job in $jobs){
	#Target only the ScheduleTrigger element type here.
	$elements = $job.Elements | ? {$_.ElementTypeName -eq "ScheduleTrigger"}

	foreach($element in $elements){
		#Update the ExceptForDate property of any Schedule Triggers
		$element.ExceptForDate = "Holidays"
	}
	$job.Update()
} 
