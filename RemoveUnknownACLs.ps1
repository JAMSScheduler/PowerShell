Import-Module JAMS
#  The following script checks all Jobs, Variables and Folders (except root \ folder)
#  for the presense of an <unknown> ACE (in the Security tab) and removes it.
#
New-PSDrive JD JAMS localhost -ErrorAction SilentlyContinue

$folders = Get-ChildItem JD:\ -ObjectType folder -Recurse -IgnorePredefined

foreach($folder in $folders){
    $folder.QualifiedName
    $objs = Get-ChildItem "JD:$($folder.QualifiedName)" 
    #
    #  Loop through all jobs and variables within the folder
    #
    foreach ($item in $objs)
    {
            $jobVarUpdated = $false;
            $jobVar = Get-Item "JD:\$($item.QualifiedName)"
            for($i = $jobVar.Acl.GenericACL.Count - 1; $i -ge 0; $i--)
            {
                # Get the ACE at the current index
                $ace = $jobVar.Acl.GenericACL[$i]
                #
                # Check if this ACE is the one want we want to remove and is not inherited
                #
                if (!($ace.Inherited) -AND $ace.Identifier.ToLower() -eq "<unknown>")   #
                {
                    Write-Host "Removed from Job or Variable: " $jobVar.QualifiedName
                    # Remove the ACE from the collection
                    $jobVar.Acl.GenericACL.Remove($ace)
                    $jobVarUpdated = $true;
                }
            }
            if($jobVarUpdated)
            {
                $jobVar.Update()
            }
    }
    #
	# Now check the Folder itself
	#
    $folderUpdated = $false;
    $thisFolder=Get-Item "JD:$($folder.QualifiedName)"
    for($i = $thisFolder.Acl.GenericACL.Count - 1; $i -ge 0; $i--)
    {
        # Get the ACE at the current index
        $ace = $thisFolder.Acl.GenericACL[$i]
        #
        # Check if this ACE is the one want we want to remove and is not inherited
        #
        if (!($ace.Inherited) -AND $ace.Identifier.ToLower() -eq "<unknown>")   #
        {
            Write-Host "Removed from Folder: " $thisFolder.QualifiedName
            # Remove the ACE from the collection
            $thisFolder.Acl.GenericACL.Remove($ace)
            $folderUpdated = $true;
        }
    }
    if($folderUpdated)
    {
        $thisFolder.Update()
    }

}
Remove-PSDrive JD
