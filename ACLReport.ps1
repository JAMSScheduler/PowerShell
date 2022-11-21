Import-Module JAMS
New-PSDrive JDB JAMS localhost
#
#Adjust below line to change output path
#
Start-Transcript -Path C:\JAMSTemp\PermissionReport.txt

$FOLDER_ACCESS  = @{    [MVPSI.JAMS.FolderAccess]::Delete = "Delete";
                        [MVPSI.JAMS.FolderAccess]::Control = "Control";
                        [MVPSI.JAMS.FolderAccess]::Change = "Change";
                        [MVPSI.JAMS.FolderAccess]::Inquire = "Inquire";
                        [MVPSI.JAMS.FolderAccess]::AddJobs = "AddJobs";
                        [MVPSI.JAMS.FolderAccess]::ChangeJobs = "ChangeJobs";
                        [MVPSI.JAMS.FolderAccess]::InquireJobs = "InquireJobs";
                        [MVPSI.JAMS.FolderAccess]::DeleteJobs = "DeleteJobs";
                        [MVPSI.JAMS.FolderAccess]::Submit = "Submit";
                        [MVPSI.JAMS.FolderAccess]::Debug = "Debug";
                        [MVPSI.JAMS.FolderAccess]::Manage = "Manage";
                        [MVPSI.JAMS.FolderAccess]::Monitor = "Monitor";
                        [MVPSI.JAMS.FolderAccess]::Abort = "Abort"
}

$JOB_ACCESS = @{    [MVPSI.JAMS.JobAccess]::Abort = "Abort";
                    [MVPSI.JAMS.JobAccess]::Change =  "Change";
                    [MVPSI.JAMS.JobAccess]::Control = "Control ";
                    [MVPSI.JAMS.JobAccess]::Debug = "Debug ";
                    [MVPSI.JAMS.JobAccess]::Delete = "Delete ";
                    [MVPSI.JAMS.JobAccess]::Inquire = "Inquire ";
                    [MVPSI.JAMS.JobAccess]::Manage = "Manage ";
                    [MVPSI.JAMS.JobAccess]::Monitor = "Monitor ";
                    [MVPSI.JAMS.JobAccess]::Submit = "Submit "
}

$VARS_ACCESS = @{   [MVPSI.JAMS.VariableRights]::Change = "Change ";
                    [MVPSI.JAMS.VariableRights]::Control = "Control ";
                    [MVPSI.JAMS.VariableRights]::Delete = "Delete ";
                    [MVPSI.JAMS.VariableRights]::Inquire = "Inquire "
}

$AGENT_ACCESS = @{  [MVPSI.JAMS.AgentAccess]::Change = "Change ";
                    [MVPSI.JAMS.AgentAccess]::Control = "Control ";
                    [MVPSI.JAMS.AgentAccess]::Delete = "Delete ";
                    [MVPSI.JAMS.AgentAccess]::Inquire = "Inquire ";
                    [MVPSI.JAMS.AgentAccess]::Manage = "Manage ";
                    [MVPSI.JAMS.AgentAccess]::Submit = "Submit "
}

$BATCH_ACCESS = @{  [MVPSI.JAMS.BatchQueueRights]::Change = "Change ";
                    [MVPSI.JAMS.BatchQueueRights]::Control = "Control ";
                    [MVPSI.JAMS.BatchQueueRights]::Delete = "Delete";
                    [MVPSI.JAMS.BatchQueueRights]::Inquire = "Inquire";
                    [MVPSI.JAMS.BatchQueueRights]::Manage = "Manage ";
                    [MVPSI.JAMS.BatchQueueRights]::Submit = "Submit "
}

$RESOURCE_ACCESS = @{   [MVPSI.JAMS.ResourceRights]::Acquire = "Acquire ";
                        [MVPSI.JAMS.ResourceRights]::Change = "Change ";
                        [MVPSI.JAMS.ResourceRights]::Control = "Control ";
                        [MVPSI.JAMS.ResourceRights]::Delete = "Delete ";
                        [MVPSI.JAMS.ResourceRights]::Inquire = "Inquire "
}

$RUNAS_ACCESS = @{     [MVPSI.JAMS.UserAccess]::Change = "Change ";
                        [MVPSI.JAMS.UserAccess]::Control = "Control ";
                        [MVPSI.JAMS.UserAccess]::GetPassword = "GetPassword ";
                        [MVPSI.JAMS.UserAccess]::Submit = "Submit "
}

function generateReadableACE {
    param($permsDict, $ace)

    $result = ""

    foreach ($key in $permsDict.Keys) {
        if ( ($key -band $ace) -ne 0 ) {
            $result += " " + $permsDict[$key]
        }
    }

    if ($result.Length -eq 0 ) {
        $result = "No access permissions set"
    }
    return $result
}

Write-Host "`n= = = = = = = = = = = = = = = = ="
Write-Host "Displaying Folder permissions..."
Write-Host "= = = = = = = = = = = = = = = = =`n"

$folderList = Get-ChildItem   "JDB:\" -Recurse -IgnorePredefined -ObjectType folder


foreach ($sys in $folderList){
    Write-output "Folder: $($sys.QualifiedName)"
    $folder = Get-Item JDB:\$($sys.QualifiedName)

     foreach ($ace in $folder.Acl.GenericACL){
        $accessNames = generateReadableACE $FOLDER_ACCESS $ace.AccessBits
        Write-output "  Identifier: $($ace.Identifier)"
        Write-output "  Access: $($accessNames)`n"

    }
}

$folderList = $null
Write-Host "`n= = = = = = = = = = = = = = = = ="
Write-Host "Displaying Job permissions..."
Write-Host "= = = = = = = = = = = = = = = = =`n"


$objectList =  Get-ChildItem   "JDB:\" -ObjectType job -Recurse -IgnorePredefined


foreach ($object in $objectList){
    Write-output "Job: $($object.QualifiedName)"

     foreach ($ace in $object.Acl.GenericACL){
        $accessNames = generateReadableACE $JOB_ACCESS $ace.AccessBits
        Write-output "  Identifier: $($ace.Identifier)"
        Write-output "  Access: $($accessNames)`n"

    }
}

$objectList = $null
Write-Host "`n= = = = = = = = = = = = = = = = = ="
Write-Host "Displaying Variable permissions..."
Write-Host "= = = = = = = = = = = = = = = = = =`n"

try
{
    $varList = Get-ChildItem JDB:\ -ObjectType variable -Recurse -IgnorePredefined
    
	foreach ($var in $varList){
        Write-output "Variable : $($var.QualifiedName)"
        $fullV = Get-Item JDB:\$($var.QualifiedName)

        foreach ($ace in $fullV.ACL.GenericACL){
            $accessNames = generateReadableACE $VARS_ACCESS $ace.AccessBits
            Write-output "  Identifier: $($ace.Identifier)"
            Write-output "  Access: $($accessNames)`n"
        }
    }
}catch{
    #
    # Log any errors
    #
    $_.Exception
    if($_.Exception.InnerException.ValidationLog)
    {
        $_.Exception.InnerException.ValidationLog.Entries
    }
}

Write-Host "`n= = = = = = = = = = = = = = = = = ="
Write-Host "Displaying Agent permissions..."
Write-Host "= = = = = = = = = = = = = = = = = =`n"

$objectList = Get-ChildItem JDB:\Agents\

foreach ($object in $objectList){
    Write-output "Agent: $($object.AgentName)"

    foreach ($ace in $object.Acl.GenericACL){
        $accessNames = generateReadableACE $AGENT_ACCESS $ace.AccessBits
        Write-output "  Identifier: $($ace.Identifier)" 
        Write-output "  Access: $($accessNames)`n" 
    }
}

Write-Host "`n= = = = = = = = = = = = = = = = = = ="
Write-Host "Displaying Batch Queue permissions..."
Write-Host "= = = = = = = = = = = = = = = = = = =`n"

$objectList = Get-ChildItem JDB:\Queues\

foreach ($object in $objectList){
    Write-output "Queue: $($object.QueueName)"

    foreach ($ace in $object.Acl.GenericACL){
        $accessNames = generateReadableACE $BATCH_ACCESS $ace.AccessBits
        Write-output "  Identifier: $($ace.Identifier)" 
        Write-output "  Access: $($accessNames)`n" 
    }
}

Write-Host "`n= = = = = = = = = = = = = = = = = ="
Write-Host "Displaying Resources permissions..."
Write-Host "= = = = = = = = = = = = = = = = = =`n"

$objectList = Get-ChildItem JDB:\Resources\

foreach ($object in $objectList){
    Write-output "Resource: $($object.ResourceName)" 
    if (  $object.ACL.IsNull ) {
        Write-output "`tNo access permissions defined"
    } else {
        foreach ($ace in $object.Acl.GenericACL){
            $accessNames = generateReadableACE $BATCH_ACCESS $ace.AccessBits
            Write-output "`tIdentifier: $($ace.Identifier)"
            Write-output "`tAccess: $($accessNames)`n"
        }    

    }
}

Write-Host "`n= = = = = = = = = = = = = = = = = = = = = = ="
Write-Host "Displaying Credential permissions..."
Write-Host "= = = = = = = = = = = = = = = = = = = = = = =`n"

$objectList = Get-ChildItem JDB:\Credentials\

foreach ($object in $objectList){
    Write-output "User :   $($object.Name)"

    if (  $object.ACL.IsNull ) {
        Write-output "`tNo access permissions defined"
    } else {
        foreach ($ace in $object.Acl.GenericACL){
            $accessNames = generateReadableACE $RUNAS_ACCESS $ace.AccessBits
            Write-output "  Identifier: $($ace.Identifier)"
            Write-output "  Access: $($accessNames)`n"
        }
    }
}

Write-Host "`n= = = = = = = = = = = = = = = = = = = = = = ="
Write-Host "Permissions list completed."
Write-Host "= = = = = = = = = = = = = = = = = = = = = = ="
Stop-Transcript