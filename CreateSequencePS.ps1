try
{
    #
    # Import the JAMS module and create a JAMS drive
    #
    Import-Module JAMS -ErrorAction SilentlyContinue
    New-PSDrive JD JAMS localhost -ErrorAction SilentlyContinue
 
    #
    # Import the JAMSSequenceShr assembly
    #
    Add-Type -Path "C:\Program Files\MVPSI\Modules\JAMS\JAMSSequenceShr.dll"
 
    #
    # Delete the Sequence Job if it already exists
    #
    if(Test-Path JD:\Samples\Seq-CreatedByPowerShell)
    {
        Remove-Item JD:\Samples\Seq-CreatedByPowerShell
    }
 
    #
    # Create the Sequence Job
    #
    $seq = New-Item -Path "JAMS::Localhost\Samples\Seq-CreatedByPowerShell" -ItemType "Job" -MethodName "Sequence"
    $seq.Description = "Created from PowerShell"
 
    #
    # Add a ScheduleTrigger element
    #
    $element = New-Object MVPSI.JAMS.ScheduleTrigger
    $element.ScheduledDate="Daily"
    $element.ScheduledTime="08:35"
    $seq.Elements.Add($element)
 
    #
    # Get the Sleep60 Job
    #
    $sleep60 = Get-Item JD:\Samples\Sleep60
 
    #
    # Create the root Sequence Task
    #
    $rootSequence = New-Object MVPSI.JAMSSequence.SequenceTask
 
    #
    # Create a SubmitJobTask and assign properties
    #
    $submitJobTask = New-Object MVPSI.JAMSSequence.SubmitJobTask
    $submitJobTask.CompletionSeverity = "Warning"
    $submitJobTask.ExceptForDate = "Saturday"
    $submitJobTask.Credential = "JAMS"
    $submitJobTask.DisplayTitle = "Submit: Sleep60"
    $submitJobTask.OverrideJobName = "Sleep60 Overriden"
    $submitJobTask.BatchQueueName = "QueueTest"
    $submitJobTask.AgentName = "Se7en"
    $submitJobTask.ScheduleForDate = "Daily"
    $submitJobTask.ScheduledTime = "3:30PM"
    $submitJobTask.SubmitJob = $sleep60
 
    #
    # Add the Job's parameters
    #
    foreach($param in $sleep60.Parameters)
    {
        #
        # Create a JobParameter element
        #
        $jobParam = New-Object MVPSI.JAMSSequence.JobParameter
        $jobParam.ParameterName = $param.ParamName
        $jobParam.ParentTaskID = $submitJobTask.ElementUid
 
        # Add the JobParameter as an associated element
        $submitJobTask.AddAssociatedElement($jobParam);
    }
 
    #
    # Connect the SubmitJobTask as a child of the Sequence
    #
    $submitJobTask.ParentTaskID = $rootSequence.ElementUid
    $rootSequence.Tasks.Add($submitJobTask)
 
    #
    # Pass the root sequence Task to the SequenceHelper to get a flat list
    #  of all elements in the sequence
    #
    $sourceElements = @{}
    [MVPSI.JAMSSequence.SequenceHelper]::GetSequenceElements([ref] $sourceElements, $rootSequence)
 
    #
    # Add the elements to the Sequence Job's SourceElements
    #
    foreach($element in $sourceElements)
    {
        $seq.SourceElements.Add($element)
    }
 
    # Save the Sequence Job
    $seq.Update()
}
catch
{
    #
    # Log any errors
    #
    $_.Exception
    if($_.Exception.InnerException.ValidationLog)
    {
        $_.Exception.InnerException.ValidationLog.Entries
    }
 }