Import-module JAMS
New-PSDrive JD JAMS localhost -ErrorAction SilentlyContinue

$folderToRemove = "JD:\PROD\"  #####! Adjust this line to change folder that will be deleted. !############

function RemoveJob ([string]$jobPath) {
    try {
        Remove-Item $jobPath -Confirm:$false -Force
        
    } catch {
        $thisJob = get-item $jobPath
        $totalReferences = $thisJob.References | Select-Object -unique | Select FolderPath, ReferringName, ElementTypeName
        foreach ($reference in $totalReferences) {
            if($reference.ElementTypeName -eq "SubmitJobTask") {
                $ref = "JD:$($reference.FolderPath)\$($reference.ReferringName)"
                RemoveJob $ref
            }
            else {
                $ref = "JD:$($reference.FolderPath)\$($reference.ReferringName)"
                $refJob = Get-Item $ref
                $refJob.elements.clear()
                $refjob.update()
            }
            
        }
    }
    finally {
        if(test-path $jobPath){
            Remove-Item $jobPath -Confirm:$false -Force
        }
    }
}

$folders=$null
$folders = Get-ChildItem $folderToRemove -ObjectType folder -recurse 
write-host "Number of folders: " $folders.count

foreach($folder in $folders){
    $jobs=$null
    $jobs = Get-ChildItem "$folderToRemove$($folder.Name)\" -ObjectType job -Recurse
    write-host "Number of jobs: " $jobs.count " in folder " $folder.Name
    foreach($job in $jobs){
        if(test-path "JD:$($job.QualifiedName)"){
            RemoveJob "JD:$($job.QualifiedName)"
        }
    }
    
    Remove-Item JD:$($folder.QualifiedName) -Confirm:$false -Force -Recurse
}

$jobs=$null
$jobs = Get-ChildItem "$folderToRemove" -ObjectType job -Recurse
foreach($job in $jobs){
    if(test-path "JD:$($job.QualifiedName)"){
        RemoveJob "JD:$($job.QualifiedName)"
    }
}
    
Remove-Item $folderToRemove -Confirm:$false -Force -Recurse