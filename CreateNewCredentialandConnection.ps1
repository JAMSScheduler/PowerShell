Import-Module JAMS
$svr = [MVPSI.JAMS.Server]::GetServer("localhost"); #Change localhost to JAMS Server

$InterfaceName = "NewConnectionFromPowerShell"

# Create the new credential to use for this interface (can be removed if not needed)
$newUser = New-Object -TypeName "MVPSI.JAMS.Credential"
$newUser.BeginEdit()
$newUser.CredentialName = $InterfaceName
$newUser.Description = "Credential used for TestingNewConnectionFromPowerShell"
$newUser.LogonUserName = "<<username>>"
$newUser.Password = '<<passwd>>'
$newUser.Validate()
$newUser.Update($svr)
$newUser.EndEdit()

# Create the new (Agent/Connection Store Object)
$newConStobj = New-Object -TypeName MVPSI.JAMS.Agent 
$newConStobj.AgentType = [MVPSI.JAMS.AgentType]::SFTP
$newConStobj.AgentTypeName= "SFTP"
$newConStobj.AgentName = $InterfaceName
$newConStobj.Description = ""
$newConStobj.PlatformTypeName = "Neutral" ###### Need to find values for this #######
$newConStobj.AgentPlatform    = "Unknown"
$newConStobj.Enabled          = $True
$newConStobj.Properties.SetValue("Credential", ([MVPSI.JAMS.CredentialReference]::new($InterfaceName)))
$newConStobj.Properties.SetValue("Address", "<<URL>>")
$newConStobj.Update($svr)

