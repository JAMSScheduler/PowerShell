### Import Module and create a JAMS drive
Import-Module JAMS
New-PSDrive JD JAMS JAMSServerName
 
### CD Into Users
CD JD:\Users
 
 
### Get the user you want to change and update password
$User = Get-Item "SomeJAMSUser"
$User.Password = "mynewpass"
$User.Update()
