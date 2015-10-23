Function DownloadFile($remotePath, $localPath)
{
$fileList = Get-JFSChildItem -Path $remotePath 
{

if($file.IsFile)
{

if((Test-Path $localFileName) -eq $false)
{
Receive-JFSItem -Name $remotePath -Destination $localPath -Verbose
}
}
}
}
