# PowerShell Checks If a File Exists
$WantFile = "C:\Windows\explorer.exe" 
$FileExists = Test-Path $WantFile 
If ($FileExists -eq $True) {
Write-Host "Got File!!!"
Send-MailMessage -To Email@Email.com -Subject "Alert!!!!" -From AnyEmail@Email.com -body "Alert Body!!!!" 
}
Else {
Write-Host "No file at this location"
}



also, could use the following to loop, checking for the file and exiting when the file exists:

$WantFile = "C:\temp\filename.txt"

while (!(Test-Path -Path $WantFile))
{
Write-Host "No file at this location"
Start-Sleep 10
}
Write-Host "File Exists!"