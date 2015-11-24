#
#Create your JAMS Drive and CD into the drive
#
New-PSDrive JD JAMS JAMSServerName
CD JD:\
#
# Create a new Trigger
#
$trig = New-Item JD:\Samples\myTestTriggerName -ItemType trigger

#
# Create a new file trigger event
#
$event = New-Object -TypeName MVPSI.JAMS.TriggerEventFile
$event.FileName = "C:\TestDir\*.ZZZ"

#
# Create an Action
#
$action = New-Object -TypeName MVPSI.JAMS.TriggerActionSetup
$action.SetupName = "\Folder\SetupName"


$trig.Actions.Add($action);
$trig.Events.Add($event);
$trig.Update();
