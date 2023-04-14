Import-Module JAMS -EA Continue
New-PSDrive JD JAMS localhost -ErrorAction SilentlyContinue

$CREDS_ACCESS = @{     [MVPSI.JAMS.UserAccess]::Change = "Change ";
                       [MVPSI.JAMS.UserAccess]::Control = "Control ";
                       [MVPSI.JAMS.UserAccess]::GetPassword = "GetPassword ";
                       [MVPSI.JAMS.UserAccess]::Submit = "Submit "
}

$CALS_ACCESS = @{     [MVPSI.JAMS.CalendarAccess]::Change = "Change";
                      [MVPSI.JAMS.CalendarAccess]::Control = "Control";
                      [MVPSI.JAMS.CalendarAccess]::Delete = "Delete";
                      [MVPSI.JAMS.CalendarAccess]::Inquire = "Inquire "
}

$VARS_ACCESS = @{   [MVPSI.JAMS.VariableRights]::Change = "Change ";
                    [MVPSI.JAMS.VariableRights]::Control = "Control ";
                    [MVPSI.JAMS.VariableRights]::Delete = "Delete ";
                    [MVPSI.JAMS.VariableRights]::Decrypt="Decrypt ";
                    [MVPSI.JAMS.VariableRights]::Inquire = "Inquire "
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

$AGENT_ACCESS = @{  [MVPSI.JAMS.AgentAccess]::Change = "Change ";
                    [MVPSI.JAMS.AgentAccess]::Control = "Control ";
                    [MVPSI.JAMS.AgentAccess]::Delete = "Delete ";
                    [MVPSI.JAMS.AgentAccess]::Inquire = "Inquire ";
                    [MVPSI.JAMS.AgentAccess]::Manage = "Manage ";
                    [MVPSI.JAMS.AgentAccess]::Submit = "Submit "
}

$QUEUE_ACCESS = @{  [MVPSI.JAMS.BatchQueueRights]::Change = "Change ";
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

$objectAccessItems = @{
        [MVPSI.JAMS.ObjectAccess]::Abort="Abort";
        [MVPSI.JAMS.ObjectAccess]::Add="Add";
        [MVPSI.JAMS.ObjectAccess]::Change="Change";
        [MVPSI.JAMS.ObjectAccess]::Control="Control";
        [MVPSI.JAMS.ObjectAccess]::Decrypt="Decrypt";
        [MVPSI.JAMS.ObjectAccess]::Delete="Delete";
        [MVPSI.JAMS.ObjectAccess]::Execute="Execute";
        [MVPSI.JAMS.ObjectAccess]::Inquire="Inquire";
        [MVPSI.JAMS.ObjectAccess]::Manage="Manage";
        [MVPSI.JAMS.ObjectAccess]::SeeAll="SeeAll";
        [MVPSI.JAMS.ObjectAccess]::SeeOwn="SeeOwn"
}

function generateAccessObject {
    param($thisArea, $permsDict, $ace)

    [System.Collections.ArrayList]$resultSet = @()
    $resultString = ""
    
    foreach ($key in $permsDict.Keys) {
        if ( ($key -band $ace.AccessBits) -ne 0 ) {
            $null = $resultSet.Add($permsDict[$key])
        }
    }
    if ($resultSet.Count -eq 0 ) {
        $resultString = "No access permissions set"
    }
    else {
        $resultString = $($resultSet -join " ")
    }
    
    Write-Host "Area: $thisArea - Identifier: $($ace.Identifier) - Access: $resultString"
    if($resultString -ne "No access permissions set")
    {
        $Area = $thisArea
        $User = "$($ace.Identifier)"
        if($resultString.Contains("Abort"))
        {
            $Abort = "X"
        }
        if($resultString.Contains("Acquire"))
        {
            $Acquire = "X"
        }
        if($resultString.Contains("Add"))
        {
            $Add = "X"
        }
        if($resultString.Contains("AddJobs"))
        {
            $AddJobs = "X"
        }
        if($resultString.Contains("Change"))
        {
            $Change = "X"
        }
        if($resultString.Contains("ChangeJobs"))
        {
            $ChangeJobs = "X"
        }
        if($resultString.Contains("Control"))
        {
            $Control = "X"
        }
        if($resultString.Contains("Debug"))
        {
            $Debug = "X"
        }
        if($resultString.Contains("Decrypt"))
        {
            $Decrypt = "X"
        }
        if($resultString.Contains("Delete"))
        {
            $Delete = "X"
        }
        if($resultString.Contains("DeleteJobs"))
        {
            $DeleteJobs = "X"
        }
        if($resultString.Contains("Execute"))
        {
            $Execute = "X"
        }
        if($resultString.Contains("GetPassword"))
        {
            $GetPassword = "X"
        }
        if($resultString.Contains("Inquire"))
        {
            $Inquire = "X"
        }
        if($resultString.Contains("InquireJobs"))
        {
            $InquireJobs = "X"
        }
        if($resultString.Contains("Monitor"))
        {
            $Monitor = "X"
        }
        if($resultString.Contains("Manage"))
        {
            $Manage = "X"
        }
        if($resultString.Contains("Submit"))
        {
            $Submit = "X"
        }
        if($resultString.Contains("SeeAllJobs"))
        {
            $SeeAllJobs = "X"
        }
        if($resultString.Contains("Abort"))
        {
            $SeeOwnJobs = "X"
        }
        $accessObject = [PSCustomObject]@{
            Area = $Area
            User = $User
            Abort = $Abort
            Acquire=$Acquire
            Add = $Add
            AddJobs=$AddJobs
            Change = $Change
            ChangeJobs=$ChangeJobs
            Control = $Control
            Debug=$Debug
            Decrypt=$Decrypt
            Delete = $Delete
            DeleteJobs=$DeleteJobs
            Execute = $Execute
            GetPassword=$GetPassword
            Inquire=$Inquire
            InquireJobs=$InquireJobs
            Manage = $Manage
            Monitor=$Monitor
            Submit = $Submit
            SeeAllJobs=$SeeAllJobs
            SeeOwnJobs=$SeeOwnJobs
        }
                                
        $Area = ""
        $User = ""
        $Abort = ""
        $Acquire=""
        $Add = ""
        $AddJobs=""
        $Change = ""
        $ChangeJobs=""
        $Control = ""
        $Debug=""
        $Decrypt=""
        $Delete = ""
        $DeleteJobs=""
        $Execute = ""
        $GetPassword=""
        $Inquire=""
        $InquireJobs=""
        $Manage = ""
        $Monitor=""
        $Submit = ""
        $SeeAllJobs=""
        $SeeOwnJobs=""
    }

    return $accessObject
}

# Get an instance of the JAMS Server
$jamsServer = [MVPSI.JAMS.Server]::GetServer("localhost")
[System.Collections.ArrayList]$auditObjects = @()

$accessitems = @(   [MVPSI.JAMS.AccessObject]::AccessControl,
                    [MVPSI.JAMS.AccessObject]::AgentDefinitions,
                    [MVPSI.JAMS.AccessObject]::CalendarDefinitions,
                    [MVPSI.JAMS.AccessObject]::Configuration, 
                    [MVPSI.JAMS.AccessObject]::CredentialDefinitions, 
                    [MVPSI.JAMS.AccessObject]::FolderDefinitions,
                    [MVPSI.JAMS.AccessObject]::History, 
                    [MVPSI.JAMS.AccessObject]::Monitor, 
                    [MVPSI.JAMS.AccessObject]::JobDefinitions, 
                    [MVPSI.JAMS.AccessObject]::VariableDefinitions, 
                    [MVPSI.JAMS.AccessObject]::QueueDefinitions,
                    [MVPSI.JAMS.AccessObject]::MenuDefinitions,
                    [MVPSI.JAMS.AccessObject]::NamedTimeDefinitions,
                    [MVPSI.JAMS.AccessObject]::Reporting,
                    [MVPSI.JAMS.AccessObject]::ResourceDefinitions,
                    [MVPSI.JAMS.AccessObject]::ServerAccess)
#
# Iterate through the AccessObject Types enumeration
#
foreach($accessType in $accessitems)
{
    #
    # Load the Security for the specified AccessObject
    #
    $sec = New-Object MVPSI.JAMS.Security
    [MVPSI.JAMS.Security]::Load([ref]$sec, $accessType, $jamsServer)

    if($accessType -eq [MVPSI.JAMS.AccessObject]::CalendarDefinitions)
    {       
        foreach ($ace in $sec.Acl.GenericACL)
        {
            $accessObject = GenerateAccessObject $accessType.ToString() $objectaccessItems $ace
            if($accessObject){
                $null = $auditObjects.Add($accessObject)
            }
        }

        $calsList = Get-ChildItem JD:\Calendars\ 
                
        foreach ($cal in $calsList){
            $specCal = Get-Item "$($cal.PSPath)$($cal.Name)"
            if (!($specCal.ACL.IsNull)) {
                foreach ($ace in $specCal.ACL.GenericACL){
                    $accessObject = GenerateAccessObject "Cal: $($specCal.Name)" $CALS_ACCESS $ace
                    if($accessObject){
                        $null = $auditObjects.Add($accessObject)
                        $accessObject=$null
                    }
                }
            }
        }
        $calsList=$null 
    }
    elseif($accessType -eq [MVPSI.JAMS.AccessObject]::CredentialDefinitions)
    {
        foreach ($ace in $sec.Acl.GenericACL)
        {
            $accessObject = GenerateAccessObject $accessType.ToString() $objectaccessItems $ace
            if($accessObject){
                $null = $auditObjects.Add($accessObject)
                $accessObject=$null
            }
        }

        $credsList = Get-ChildItem JD:\Credentials\

        foreach ($cred in $credsList){
            if (!($cred.ACL.IsNull)) {
                foreach ($ace in $cred.ACL.GenericACL){
                    $accessObject = GenerateAccessObject "Cred: $($cred.Name)" $CREDS_ACCESS $ace
                    if($accessObject){
                        $null = $auditObjects.Add($accessObject)
                        $accessObject=$null
                    }
                }
            }
        }
        $credsList=$null   
    }   
    elseif($accessType -eq [MVPSI.JAMS.AccessObject]::FolderDefinitions)
    {               
        foreach ($ace in $sec.Acl.GenericACL)
        {
            $accessObject = GenerateAccessObject $accessType.ToString() $objectaccessItems $ace
            if($accessObject){
                $null = $auditObjects.Add($accessObject)
                $accessObject=$null
            }
        }
        try
        {
            $folderList = Get-ChildItem JD:\ -ObjectType folder -Recurse -IgnorePredefined
    
	        foreach ($folder in $folderList){
                $fullFolder = Get-Item JD:\$($folder.qualifiedName)

                foreach ($ace in $fullFolder.ACL.GenericACL){
                    $accessObject = GenerateAccessObject "Folder: $($folder.QualifiedName)" $FOLDER_ACCESS $ace
                    if($accessObject){
                        $null = $auditObjects.Add($accessObject)
                    }
                }
            }
        }
        catch{
            #
            # Log any errors
            #
            $_.Exception
            if($_.Exception.InnerException.ValidationLog)
            {
                $_.Exception.InnerException.ValidationLog.Entries
            }
        }
        $folderList=$null 
    } 
    elseif($accessType -eq [MVPSI.JAMS.AccessObject]::VariableDefinitions)
    {
        foreach ($ace in $sec.Acl.GenericACL)
        {
            $accessObject = GenerateAccessObject $accessType.ToString() $objectaccessItems $ace
            if($accessObject){
                $null = $auditObjects.Add($accessObject)
                $accessObject=$null
            }
        }

        try
        {
            $varList = Get-ChildItem JD:\ -ObjectType variable -Recurse -IgnorePredefined
    
	        foreach ($var in $varList){
                $fullV = Get-Item JD:\$($var.QualifiedName)

                foreach ($ace in $fullV.ACL.GenericACL){
                    $accessObject = GenerateAccessObject "Var: $($fullV.QualifiedName)" $VARS_ACCESS $ace
                    if($accessObject){
                        $null = $auditObjects.Add($accessObject)
                        $accessObject=$null
                    }

                }
            }
        }
        catch{
            #
            # Log any errors
            #
            $_.Exception
            if($_.Exception.InnerException.ValidationLog)
            {
                $_.Exception.InnerException.ValidationLog.Entries
            }
        }

        $varList=$null 
    }
    elseif($accessType -eq [MVPSI.JAMS.AccessObject]::JobDefinitions)
    {
        foreach ($ace in $sec.Acl.GenericACL)
        {
            $accessObject = GenerateAccessObject $accessType.ToString() $objectaccessItems $ace
            if($accessObject){
                $null = $auditObjects.Add($accessObject)
            }
        }

        try
        {
            $folderList = Get-ChildItem JD:\ -ObjectType folder -Recurse -IgnorePredefined
    
	        foreach ($folder in $folderList){
                $jobsList = Get-ChildItem JD:\$($folder.QualifiedName) -ObjectType job -IgnorePredefined
                foreach($job in $jobsList){
                    $fullJob = Get-Item JD:\$($job.qualifiedName)

                    foreach ($ace in $fullJob.ACL.GenericACL){
                        $accessObject = GenerateAccessObject "Job: $($fullJob.QualifiedName)" $JOB_ACCESS $ace
                        if($accessObject){
                            $null = $auditObjects.Add($accessObject)
                        }

                    }
                }
            }
        }
        catch{
            #
            # Log any errors
            #
            $_.Exception
            if($_.Exception.InnerException.ValidationLog)
            {
                $_.Exception.InnerException.ValidationLog.Entries
            }
        }

        $folderList=$null 
        $jobsList=$null 
    }
    elseif($accessType -eq [MVPSI.JAMS.AccessObject]::AgentDefinitions)
    {
                
        foreach ($ace in $sec.Acl.GenericACL)
        {
            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace
            if($accessObject){
                $null = $auditObjects.Add($accessObject)
                $accessObject=$null
            }
        }

        $agentsList = Get-ChildItem JD:\Agents\
        
        foreach ($agent in $agentsList){
        
            if (!($agent.ACL.IsNull)) {
                foreach ($ace in $agent.ACL.GenericACL){
                    $accessObject = GenerateAccessObject "Agent: $($agent.AgentName)" $AGENT_ACCESS $ace
                    if($accessObject){
                        $null = $auditObjects.Add($accessObject)
                        $accessObject=$null
                    }
                }
            }
        }
        $agentsList=$null   
    }
    elseif($accessType -eq [MVPSI.JAMS.AccessObject]::QueueDefinitions)
    {
        foreach ($ace in $sec.Acl.GenericACL)
        {
            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace
            if($accessObject){
                $null = $auditObjects.Add($accessObject)
                $accessObject=$null
            }
        }
        
        $queueList = Get-ChildItem JD:\Queues\
        
        foreach ($queue in $queueList){
        
            if (!($queue.ACL.IsNull)) {
                foreach ($ace in $queue.ACL.GenericACL){
                    $accessObject = GenerateAccessObject "Queue: $($queue.Name)" $QUEUE_ACCESS $ace
                    if($accessObject){
                        $null = $auditObjects.Add($accessObject)
                        $accessObject=$null
                    }
                }
            }
        }
        $queueList=$null  
    }   
    elseif($accessType -eq [MVPSI.JAMS.AccessObject]::ResourceDefinitions)
    {
                
        foreach ($ace in $sec.Acl.GenericACL)
        {
            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace
            if($accessObject){
                $null = $auditObjects.Add($accessObject)
                $accessObject=$null
            }
        }
        
        $resourceList = Get-ChildItem JD:\Resources\
        
        foreach ($resource in $resourceList){
        
            if (!($resource.ACL.IsNull)) {
                foreach ($ace in $resource.ACL.GenericACL){
                    $accessObject = GenerateAccessObject "Resource: $($resource.Name)" $RESOURCE_ACCESS $ace
                    if($accessObject){
                        $null = $auditObjects.Add($accessObject)
                        $accessObject=$null
                    }
                }
            }
        }
        $resourceList=$null  
    }   
    else #if $accessType -in ServerAccess, Reporting, NamedTimeDefinitions, MenuDefinitions, History, AccessControl, Monitor, Configuration
    {                
        foreach ($ace in $sec.Acl.GenericACL)
        {
            $accessObject = GenerateAccessObject $accessType.ToString() $objectAccessItems $ace
            if($accessObject){
                $null = $auditObjects.Add($accessObject)
                $accessObject=$null
            }
        }
    }
}

$auditObjects|FT
$auditObjects|Export-Csv -Path C:\Temp\FullJAMSAuditReport.csv -NoTypeInformation
