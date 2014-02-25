#
# [Options]
#
Write-Host "Filemask: " >    # the files to look for (i.e. *.xml)
Write-Host "SFTP Option: " >   # 1 for SFTP or 0 for FTP
Write-Host "Expected Count: " >  # the expected number of files to find
Write-Host "FTP Cred: " >   # FTP site credentials
Write-Host "Extra FTP Params:" >   # extra parameters (i.e. -PASSIVE)
Write-Host "FTP Host Name:" >   # FTP Site name or IP address
Write-Host "Remote Source Location:" >   # remote directory
Write-Host "Sleep Time:" > # Sleep time in seconds between checks
$foundFiles = $false

do
{
   #
   # [Set counter]
   #
   $counter = 0

   #
   #[Get Credentials from a JAMS User]
   #
   $userCredentials = Get-JAMSCredential -UserName ">" -Server localhost


   #
   # [Establishing a Connection. Check whether to use SFTP or FTP]
   #
   $SFTP = >
   if ($SFTP -eq 1)
   {
     Write-Host "Attempting to connect via JSFTP"
     Connect-JSFTP > -JAMSCredential $userCredentials -Name ">"
   }
   else
   {
    Write-Host "Attempting to connect via JFTP"
     Connect-JFTP > -Credential $userCredentials -Name ">"
   }

   #
   # [Set the Remote Location]
   #
   if(">".Length -gt 0)
   {
     Set-JFSLocation ">"
   }

   #
   # [If an array of File masks was provided look through each]
   #
   if(">".Contains(','))
   {
     Write-Host "Filemask is an Array"     

     #
     # [Split the Filters into an Array]
     #
     $filterAry = ">".Split(',')
     
     #
     # [Check for files matching each mask]
     #
    foreach($filter in $filterAry)
    {
         Write-Host "Current Mast:$filter"
       
         #
         # [Look for files matching the filemask]
         #
         Get-JFSChildItem $filter | ? {$_.IsFile -eq $true} | ForEach-Object {
       
         #
         # [File Found, increment counter]
         #   
         Write-Host "File found: " $_.name
         $counter = $counter + 1
         }
    }
   }
   else
   {
     #
     # [Look for files matching the filemask]
     #
     Get-JFSChildItem ">" | ? {$_.IsFile -eq $true} | ForEach-Object {
       
       #
       # [File Found, increment counter]
       #   
       Write-Host "File found: " $_.name
       $counter = $counter + 1
     }
   }

   #
   #[Disconnect from the server]
   #
   Disconnect-JFS

   Set-JAMSStatus "Found $counter matching files." -ErrorAction "Continue"

   #
   # [If files were found continue processing. Otherwise sleep and try again]
   #
   if ($counter -ge >)
   {   
     Write-Host "$counter File(s) found!"
     $foundFiles = $true
   }
   else 
   {
     #
     # [Files not found]
     #
     Write-Host "Files not ready will try again in > seconds."
     Write-Host "Found $counter of > files."
     Start-Sleep >
   }
}
while($foundFiles -eq $false)