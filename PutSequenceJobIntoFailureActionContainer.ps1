#Update the Path for the DLL! (This is a custom installation path)
Add-Type -Path "C:\Program Files\MVPSI\Modules\JAMS\JAMSSequenceShr.dll"

$seq = get-item JAMS::localhost\IIB\Seq-IIB_P_DOM_PKMS_ASNTYPEI_HOURLY_BXS 
$termJobs = $seq.SourceElements | Where-Object { ( $_.ElementName -in @("UNX_P_DOM_PKMS_ASNTYPEI_BL_HOURLY", "UNX_P_DOM_PKMS_ASNTYPEI_RD_HOURLY", "UNX_P_DOM_PKMS_ASNTYPEI_JK_HOURLY") ) }  

Foreach($jobTask in $termJobs) {
    $jobTask.ElementName
    
    # Get Curent Parent
    $curParent = $seq.SourceElements | Where-Object { ( $_.ElementUid -eq $jobTask.ParentTaskID ) }
    
    [int]$InsertIndex=$seq.SourceElements.IndexOf($jobTask)
    #$InsertIndex

    $newContainer = New-Object -TypeName MVPSI.JAMSSequence.FailureActionTask 
    $newContainer.CategorySortOrder=$jobTask.CategorySortOrder
    $newContainer.ElementId=$jobTask.ElementId
    $newContainer.FailureAction = [MVPSI.JAMS.FailureAction]::Fail
    $newContainer.SortOrder=$jobTask.SortOrder

    $jobTask.ParentTaskID = $newContainer.ElementUid
    
    $newContainer.Tasks.Add($jobTask)
    
    if($curParent -ne $null) {
        $newContainer.ParentTaskID=$curParent.ElementUid
        $curParent.Tasks.Add($newContainer)
        
        foreach($newTask in $curParent.Tasks){

            if($seq.SourceElements.Contains($newTask)){
                #Do nothing
            }
            Else{ #Add new task
                
                $seq.SourceElements.Insert($InsertIndex, $newTask)
            }
        }
    }
    else {
        $seq.SourceElements.Insert($InsertIndex, $newContainer)
    }
}
#$seq.CancelEdit()
$seq.Update()