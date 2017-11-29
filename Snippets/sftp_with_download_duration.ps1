# This script serves as an example for how to display the time a 
# file download took.

#Connect to the server
Connect-JSFTP -JAMSCredential (Get-JAMSCredential ftpacct) -AcceptKey -Binary -Name 123.123.123.123
 
# CD to specific location on the SFTP server
Set-JFSLocation downloads
 
# Get the file, and record the download time - this will also output transfer speed
$TotalTransferTime = Measure-Command {
    Receive-JFSItem ourFile.db -Destination 'C:\Users\Admin\Downloads\' -Verbose
}
 
# Output the duration of the file transfer
Write-Host "Transfer Duration: $TotalTransferTime"
