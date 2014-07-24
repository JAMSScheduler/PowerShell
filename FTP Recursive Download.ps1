#
# This script recursively downloads files from an ftp site. This script should only
#  be used when the server does not support: Receive-JFSItem -Recurse
#


#
# Import the JAMS Module
#
Import-Module JAMS

#
# Define connection information
#
$cred = "JAMSUserName"
$ftpSvr = "ftpServerName"
$jamsSvr = "jamsSvrName"

# The local path to update
$path = "P:"

New-PSDrive -Name P -Root "\\Left\Source\" -PSProvider FileSystem -ErrorAction SilentlyContinue

# Move into the source directory
Set-Location $path

#
# Recursive function that pulls content from an FTP server and builds locally
#
Function GetFTPItem($ftpItem)
{
    #
    # Is this a Directory?
    #
    if($_.IsDirectory)
    {
        $getDirectory = $false

      # Create the directory locally if it doesn't exist
      if(!(Test-Path $_.Name))
      {
        New-Item -ItemType Directory -Name $_.Name
      }

      # Set location into the directory
      Set-Location $_.Name

      #
      # Is this directory called Zip? If so we don't want to pull it if the current time is between 12am and 9am
      #
      if($_.Name -eq "Zip")
      {
            #
            # If its later than 9am we want to pull from this directory
            #
            if((Get-Date).Hour -gt 9)
            {
                $getDirectory = $true
            }
      }
      else
      {
        $getDirectory = $true
      }

      # Get the directory if we need to
      if($getDirectory)
      {
        Write-Host "Getting Directory: " $_.Name
        Set-JFSLocation $_.Name
        Get-JFSChildItem | %{ GetFTPItem($_) }
        Set-JFSLocation ..
      }

      # Move back up a level
      Set-Location ..
    }
    else
    {
      $getFile = $false

      #
      # Does this file already exist locally?
      #
      if(Test-Path $_.Name)
      {
        # Get the local file
        $file = GCI $_.Name

        #
        # Is it newer than the local file?
        #
        if($_.Modified -gt $file.LastWriteTime)
        {
            $getFile = $true
        }
      }
      else
      {
        $getFile = $true
      }
      
      # Download the file if it's new or updated
      if($getFile)
      {
           Write-Host "Getting File: " $_.FullName

           # Note: To work on a network share or PS Drive we have to supply the full destination path
           Receive-JFSItem $_.FullName  ("{0}\{1}" -f (pwd),$_.Name)
           
           # Set the Last write time to match what is on the Server
           $file = GCI $_.Name 
           $file.LastWriteTime = $_.Modified
      }
    }
}

#
# Connect to the FTP Server
#
Connect-JFTP -Credential (Get-JAMSCredential -Username $cred -Server $jamsSvr) -Name $ftpsvr

#
# Recursively get all content
#
Get-JFSChildItem | %{ GetFTPItem($_) }