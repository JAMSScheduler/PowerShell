#
# The following PowerShell script is a code example that can create a rolling archive
# For a file being date and time stamped. This is particularly useful for creating a complex
# Chain/Setup for processing with continuous archive for files being handled for any ETL processes.
#


#
# Check and see if we have the folder and sub folder structure created for archives
#
$topLevel = "D:\ftp\correspondents\Intake\" + [DateTime]::Now.ToString("MM-yyyy")
$subLevel = $toplevel + "\" + [DateTime]::Now.ToString("MM-dd-yyyy")

if (!(Test-Path -path $topLevel))
{
    New-Item $topLevel -type directory
    Write-Host "$topLevel created - continuing process"
}
else {
    Write-Host "$topLevel exists - continuing process"
}
if (!(Test-Path -path $subLevel))
{
    New-Item $subLevel -type directory
    Write-Host "$subLevel created - continuing process"
}
else {
    Write-Host "$subLevel exists - continuing process"
}

#
# Check and see if we have anything in the directory
# If it is, end the execution 
#
$WorkingPath = "D:\ftp\correspondents\Intake\"

$directoryInfo = Get-ChildItem -File $WorkingPath | Measure-Object
if ($directoryInfo.count -eq 0) {
    Write-Host "Directory is empty!"
    break
}

#
# Environment variables
#
$filePath = Get-ChildItem -path $WorkingPath -File | select -First 1

Write-Host $filePath

#
# Using the Path Class, define the new file name with date and time stamp added
# Append "PROCESSED" to the start of the filename
#
$directory = [System.IO.Path]::GetDirectoryName($filePath)
$strippedFileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
$extension = [System.IO.Path]::GetExtension($filePath)
$newFileName = "PROCESSED" + "." + [DateTime]::Now.ToString("yyyyMMdd-HHmmss") + "." + $strippedFileName + $extension
$newFilePath = [System.IO.Path]::Combine($directory, $newFileName)

#
# Rename the file 
#
$combined = $WorkingPath + $filePath
Move-Item -LiteralPath $combined -Destination $newFilePath

#
# Move the file
#
Move-Item -LiteralPath $newFilePath -Destination $subLevel

#
# Copy the file to a UNC share for us to grab for any ETL processing
#
Write-Output "Copying Files"
$copyFile = $subLevel + "\" + $newFileName
Copy-Item $copyFile -Destination \\our-etl.server.name\\process\folder