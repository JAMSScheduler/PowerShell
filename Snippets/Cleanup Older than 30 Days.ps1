#
# The following script is utilized for file cleanup on a given set
# Of defined directories - in this case 4 separate directories.
# This script can be modified to clean up more, or less, locations
# And filter based upon your needs on your server(s).
#


#
# Define todays date
#
$Now = Get-Date

#
# Minimum age files must be to be deleted
#
$Days = "30"

#
# Set our targer folders to remove files from - these can be remote
# directories on Agent machines, or simply UNC paths.
#
$TargetFolder1 = "\\server1\c$\logs"
$TargetFolder2 = "\\server1\c$\dataFiles"
$TargetFolder3 = "\\server2\c$\logs" 
$TargetFolder4 = "\\seixbbgw2\c$\dataFiles"

#
# Delete only certain file extentions - or files with a certain naming convention 
#
$Extension = "*.*"

#
# Define LastWriteTime parameter based on $Days
#
$LastWrite = $Now.AddDays(-$Days)

#
# Check and delete any files in the first defined location
#
$Files1 = Get-Childitem $TargetFolder1 -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

foreach ($File in $Files1)
{
    if ($File -ne $NULL)
    {
        Write-Host "Deleting File $File"
        Remove-Item $File.FullName | out-null
    }
}

#
# Check and delete any files in the second defined location
#
$Files2 = Get-Childitem $TargetFolder2 -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

foreach ($File in $Files2)
{
    if ($File -ne $NULL)
    {
        Write-Host "Deleting File $File"
        Remove-Item $File.FullName | out-null
    }
}    

#
# Check and delete any files in the third defined location
#
$Files3 = Get-Childitem $TargetFolder3 -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

foreach ($File in $Files3)
{
    if ($File -ne $NULL)
    {
        Write-Host "Deleting File $File"
        Remove-Item $File.FullName | out-null
    }
}    
        
#
# Check and delete any files in the fourth defined location
#
$Files4 = Get-Childitem $TargetFolder4 -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

foreach ($File in $Files4)
{
    if ($File -ne $NULL)
    {
        Write-Host "Deleting File $File"
        Remove-Item $File.FullName | out-null
    }
}