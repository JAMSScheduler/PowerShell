### Begin Script
 
Import-Module JAMS
###We need to define the default JAMS server name
$JAMSDefaultServer = 'JAMSServerName'
 
New-PSDrive JD JAMS JAMSServerName
 
###We loop through our folder list and we need to specify the object type 'Folder'
###This will return a list of Folders and each ACL and their permissions only if there are ACL's assigned to those folders.
$folderList = Get-ChildItem JD:\ -Recurse -IgnorePredefined 
foreach ($sys in $folderList)
{
 If($($sys.FolderName) -ne $null){
 Write-Host "Folder: $($sys.FolderName)"
    }

 foreach ($ace in $sys.Acl.GenericACL)
 {
        $accessNames = ""
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::Execute) -ne 0)
  {
   $accessNames = $accessNames + "Execute "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::Delete) -ne 0)
  {
   $accessNames = $accessNames + "Delete "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::Control) -ne 0)
  {
   $accessNames = $accessNames + "Control "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::Change) -ne 0)
  {
   $accessNames = $accessNames + "Change "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::Inquire) -ne 0)
  {
   $accessNames = $accessNames + "Inquire "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::AddJobs) -ne 0)
  {
   $accessNames = $accessNames + "AddJobs "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::ChangeJobs) -ne 0)
  {
   $accessNames = $accessNames + "ChangeJobs "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::InquireJobs) -ne 0)
  {
   $accessNames = $accessNames + "InquireJobs "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::DeleteJobs) -ne 0)
  {
   $accessNames = $accessNames + "DeleteJobs "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::Submit) -ne 0)
  {
   $accessNames = $accessNames + "Submit "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::Debug) -ne 0)
  {
   $accessNames = $accessNames + "Debug "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::Manage) -ne 0)
  {
   $accessNames = $accessNames + "Manage "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::Monitor) -ne 0)
  {
   $accessNames = $accessNames + "Monitor "
  }
  if (($ace.AccessBits -band [MVPSI.JAMS.FolderAccess]::Abort) -ne 0)
  {
   $accessNames = $accessNames + "Abort "
  }
  Write-Host " Identifier: $($ace.Identifier)"
        Write-Host " Access: $($accessNames)"
 }
}
 
### End Script
