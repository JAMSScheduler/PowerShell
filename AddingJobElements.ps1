$Job = get-item JD:\Samples\SleepJob

#
# Add a ScheduleTrigger element
#
$element = New-Object MVPSI.JAMS.ScheduleTrigger
$element.ScheduledDate="Every Other Sunday"
$element.ScheduledTime="08:35"
$element.Enabled = $false
$Queue = Get-Item JD:\Queues\SampleTestQueue 
$Job.BatchQueue = $Queue

$job.Elements.Add($element)
$job.Update()

#
# Add a stalled Element
#
$StalledElement = New-Object -TypeName MVPSI.JAMS.StalledEvent
$StalledElement.Elapsed="00:15"
$StalledElement.EventClass ="Moderate"
$StalledElement.Message ="JOB IS STALLED"

$job.Elements.Add($StalledElement)
$job.Update()

#
# Add a Runaway element
#
$RunawayElement =  New-Object -TypeName MVPSI.JAMS.RunawayEvent
$RunawayElement.Elapsed = "01:15"
$RunawayElement.RunawayAction = "NoAction"
$RunawayElement.EventClass = "Low"
$job.Elements.Add($RunawayElement)
$job.Update()
