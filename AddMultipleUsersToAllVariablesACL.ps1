#This script will be used to add ACEs to all Variables in the specified folders

#Import the JAMS Modules and mount the JAMS filesystem
Import-Module JAMS
New-PSDrive JD JAMS localhost -EA SilentlyContinue

#Specify the AD user(s)/group(s) using domain\user format.
# Can be used for a single identifier, or expanded for a longer list
$Identifiers = @("ACMECORP\User1", "ACMECORP\Group1")

#Get all variables on a specific folder
# Modify the folder path to target other folders, or add -Recurse to find all JAMS variables.
$Variables = Get-ChildItem JD:\ -ObjectType variable 

<#
Loop through our Variables and Identifiers 
and add permissions to all Variables
#>

foreach($var in $variables)
{
    foreach($id in $Identifiers)
    {
        #Define a new ACL Object Type
        $acl = New-Object MVPSI.JAMS.GenericACE
        $acl.Identifier = $id
        $acl.AccessBits = ([MVPSI.JAMS.VariableAccess]::Change -bor [MVPSI.JAMS.VariableAccess]::Control -bor [MVPSI.JAMS.VariableAccess]::Decrypt -bor [MVPSI.JAMS.VariableAccess]::Delete -bor [MVPSI.JAMS.VariableAccess]::Inquire)
    
        $var.ACL.GenericACL.Add($acl)
       
    }
		#Update the variables 
        Write-Host "Updating variable: $var"
        $var.Update()
}



