### Powershell script to use JAMS to download all files with a specific file mask to a destination folder up to 3 folders deep for each folder in the root of the FTP directory
### The script will pick out the specified files in each folder only, it will not download the folders themselves.

### Import the JAMS module
Import-Module JAMS

### Get JAMS Credential to connect to FTP
$creds = Get-JAMSCredential -Username FTPUser

### Connect to the FTP server
Connect-jftp -Name localhost -Binary -Passive -Credential $creds -Verbose

### Get all of the objects in FTP root
$ftp = Get-JFSChildItem

### Define FileMask and Destination folders
$fileMask = "*.gpg"
$destination = "C:\Temp\FTPDownload"

### Receive files in Root Folder
Receive-JFSItem $fileMask -Destination $destination -Verbose

### Loop through each object in the root folder, if it is a folder set location to it, then download all of the files in the folder
ForEach($object in $ftp){

    ### If the object is a folder set location to it, download the files in it
    If($object.IsDirectory -eq $true){
    
        
        Write-Host "Found Folder: "$object.FullName
        $path = "/" + $object.FullName + "/"
        Set-JFSLocation $path -Verbose
        Receive-JFSItem $fileMask -Destination $destination -Verbose

        ### Get all of the objects in the second level subfolder
        $ftpfolder2 = Get-JFSChildItem
        ForEach($object2 in $ftpfolder2){
        
            If($object2.IsDirectory -eq $true){
            
                Write-Host "Found Folder: "$object2.FullName
                $path2 = $path + $object2.FullName + "/"
                Set-JFSLocation $path2 -Verbose
                Receive-JFSItem $fileMask -Destination $destination -Verbose

                ### Get all of the objects in the third level subfolder
                $ftpfolder3 = Get-JFSChildItem
                ForEach($object3 in $ftpfolder3){
                    
                    If($object3.IsDirectory -eq $true){
            
                        Write-Host "Found Folder: "$object3.FullName
                        $path3 = $path2 + $object3.FullName + "/"
                        Set-JFSLocation $path3 -Verbose
                        Receive-JFSItem $fileMask -Destination $destination -Verbose


            
            
                        }
            
        
                }

            
            
            }
            
        
        }
        
    
    }
    
}

Disconnect-JFS
