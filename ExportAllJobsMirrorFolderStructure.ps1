Import-Module JAMS
new-psdrive JD JAMS localhost -ErrorAction SilentlyContinue

Start-Transcript -Path C:\Temp\PSOutput$(get-date -format yyyy-MM-dd-hhmmss).log

$FullFolderList = get-childitem JD:\ -Recurse -ObjectType folder -IgnorePredefined
    
foreach($row in $FullFolderList){
        
    if( !($row.qualifiedname.Contains("Samples")) -and !($row.qualifiedname.Contains("\JAMS")))
    {
            
        $parentFolder = "JD:$($row.qualifiedname)\"
        $jobs = Get-ChildItem $parentFolder -ObjectType job -IgnorePredefined

		#below line can be used to export jobs in Root folder, if any are placed there.
        #$jobs = Get-ChildItem JD:\ -ObjectType job -IgnorePredefined

        foreach($job in $jobs) {
            
            $thisJob = get-item JD:\$($job.qualifiedName)
            $exportFileName=$thisJob.Name
            ##
            ## CHANGE EXPORT PATH HERE
            ##
            $exportPath = $parentFolder.Replace("JD:", "C:\JAMSExport\TempOutput")
            if (!(test-path $exportPath)){
                New-Item -Path "$exportPath" -ItemType Directory
            }
            if($thisJob -ne $null){
                write-host "$exportPath\$exportFileName.xml"
                Export-JAMSXml -InputObject $thisJob -Path "$exportPath\$exportFileName.xml" -IgnoreACL -Server localhost 
            }
        }
    }                      
}

Stop-Transcript