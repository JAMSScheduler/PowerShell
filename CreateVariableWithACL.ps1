Import-Module JAMS
$svr = [MVPSI.JAMS.Server]::GetServer("localhost"); #Change localhost to JAMS Server

New-PSDrive JD JAMS $svr

$newVar = New-Object -TypeName "MVPSI.JAMS.Variable"
$newVar.BeginEdit()
$newVar.Name = "psVariableTest" # "<<VariableName>>"
$newVar.DataType = "Text"
$newVar.Value="testvalue" # "$AgentList"
$newVar.ParentFolderName="\Samples" # 
#change value of $ADGroup to the domain group you want to grant access for.
$ADGroup = "df-JAMS7-2\dtest"
$ace = New-Object MVPSI.JAMS.GenericACE
$ace.Identifier = $ADGroup
#change the access bits below to add or remove permissions
$ace.AccessBits = ([MVPSI.JAMS.VariableAccess]::Control -bor [MVPSI.JAMS.VariableAccess]::Inquire -bor [MVPSI.JAMS.VariableAccess]::Change)
$newVar.ACL.GenericACL.Add($ace)

$newVar.Validate()

$newVar.Update($svr)
$newVar.EndEdit()

Remove-PSDrive JD