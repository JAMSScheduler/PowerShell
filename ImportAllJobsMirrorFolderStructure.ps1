Import-Module JAMS
new-psdrive JD JAMS localhost -ErrorAction SilentlyContinue

Start-Transcript -Path C:\Temp\PSOutput$(get-date -format yyyy-MM-dd-hhmmss).log

$rootFolderPath = "C:\JAMS"

$jobsPath = get-childitem -Path $rootFolderPath -Recurse -Filter *.xml
    
foreach($jobFileName in $jobsPath){
    $relativePath = $jobFileName.FullName.Replace($rootFolderPath, "").TrimStart("\")
	$jamsFolder = (Split-Path $relativePath -Parent)
	
	$jamsMountPath = "JD:\$jamsFolder"
	if(!(Test-Path $jamsMountPath)) {
		Write-Host "Creating Folder: $jamsMountPath"
		New-Item -Path $jamsMountPath -ItemType Folder
	}
	Set-Location $jamsMountPath
	$jobLocalFilePath = "$rootFolderPath\$jamsFolder\$jobFileName"
	Write-Host "Creating Job in Jams : $(jobFileName) in $(jamsMountPath)"
	Import-JAMSXml -Path $jobLocalFilePath -IgnoreACL -Server localhost
}

Stop-Transcript