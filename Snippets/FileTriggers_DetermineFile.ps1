#
# Get the Qualified Trigger Name that submitted this Job
#
$triggerName = "<<JAMS.Trigger.QualifiedName>>"

# Get the Trigger itself
$trigger = GCI "JAMS::localhost$($triggerName)"

#
# Get the files that matched each of the FileEvents
#
foreach($event in $trigger.Events)
{
  if($event -is [MVPSI.JAMS.TriggerEventFile])
 {
  # This is the path defined on the File Event which could include wildcards
  Write-Host "Event: "$event.FileName
  
  # Since this could contain wild cards we may get multiple files, for each file write out the name of each qualifying file
  GCI $event.FileName | %{
  
    # Output the file name
    Write-Host "Found File: "$_.FullName
   }
 }
}
