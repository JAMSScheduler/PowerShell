#
# [Options]
#
Write-Host "Filemask: " <<filemask>>
Write-Host "SFTP Option: " <<SFTP>>
Write-Host "Expected Count: " <<PRECHECK>>
Write-Host "FTP Cred: " <<FTPCred>>
Write-Host "Extra FTP Params:" <<FTPPARAMS>>
Write-Host "FTP Host Name:" <<FTPHostName>>
Write-Host "Remote Source Location:" <<REMOTESOURCEPATH>>
Write-Host "Sleep Time:" <<RESUBMITSLEEP>>
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
	$userCredentials = Get-JAMSCredential -UserName "<<FTPCred>>" -Server localhost

	#
	# [Establishing a Connection. Check whether to use SFTP or FTP]
	#
	$SFTP = <<SFTP>>
	if ($SFTP -eq 1)
	{
		Write-Host "Attempting to connect via JSFTP"
		Connect-JSFTP <<FTPPARAMS>> -JAMSCredential $userCredentials -Name "<<FTPHostName>>"
	}
	else
	{
	  Write-Host "Attempting to connect via JFTP"
		Connect-JFTP <<FTPPARAMS>> -Credential $userCredentials -Name "<<FTPHostName>>"
	}

	#
	# [Set the Remote Location]
	#
	if("<<REMOTESOURCEPATH>>".Length -gt 0)
	{
		Set-JFSLocation "<<REMOTESOURCEPATH>>"
	}

	#
	# [If an array of File masks was provided look through each]
	#
	if("<<filemask>>".Contains(','))
	{
		Write-Host "Filemask is an Array"		

		#
		# [Split the Filters into an Array]
		#
		$filterAry = "<<filemask>>".Split(',')
	    
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
		Get-JFSChildItem "<<filemask>>" | ? {$_.IsFile -eq $true} | ForEach-Object {
			
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
	if ($counter -ge <<PRECHECK>>)
	{	
		Write-Host "$counter File(s) found!"
		$foundFiles = $true
	}
	else 
	{
		#
		# [Files not found]
		#
		Write-Host "Files not ready will try again in <<RESUBMITSLEEP>> seconds."
		Write-Host "Found $counter of <<PRECHECK>> files."
		Start-Sleep <<RESUBMITSLEEP>>
	}
}
while($foundFiles -eq $false)