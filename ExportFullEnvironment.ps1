# This script will export all exportable JAMS objects
# 
# Set Export working directory in line below.  Should be only necessary edit.
$ExportDirectory="C:\JAMSExport\EnvironmentExport$(Get-Date -Format MMddyyyy)"

Import-Module JAMS
new-psdrive JD JAMS localhost -ErrorAction SilentlyContinue


Start-Transcript -Path $ExportDirectory\EnvironmentExport_$(get-date -format yyyy-MM-dd-hhmmss).log

#Export Variables and Jobs first
$FullFolderList = get-childitem JD:\ -Recurse -ObjectType folder -IgnorePredefined
foreach($folder in $FullFolderList){
        
    $parentFolder = "JD:$($folder.qualifiedname)\"
    
    $thisFolder = Get-Item "JD:$($folder.qualifiedname)\"
    $exportFolderFileName="folder_$($thisFolder.Name)"

    $folderExportPath = "JD:$($thisFolder.QualifiedFolderName)".Replace("JD:", "$ExportDirectory\Definitions")
    if (!(test-path $folderExportPath)){
        New-Item -Path "$folderExportPath" -ItemType Directory
    }
    if($thisFolder -ne $null){
        write-host "$folderExportPath$exportFolderFileName.xml"
        Export-JAMSXml -InputObject $thisFolder -Path "$folderExportPath\$exportFolderFileName.xml" -IgnoreACL -Server localhost 
    }

    $vars = Get-ChildItem $parentFolder -ObjectType variable -IgnorePredefined

    foreach($var in $vars) {
            
        $thisVar = get-item JD:\$($var.qualifiedName)
        $exportFileName="var_$($thisVar.Name)"

        $varExportPath = $parentFolder.Replace("JD:", "$ExportDirectory\Definitions")
        if (!(test-path $varExportPath)){
            New-Item -Path "$varExportPath" -ItemType Directory
        }
        if($thisVar -ne $null){
            write-host "$varExportPath$exportFileName.xml"
            Export-JAMSXml -InputObject $thisVar -Path "$varExportPath\$exportFileName.xml" -IgnoreACL -Server localhost 
        }
    }

    $jobs = Get-ChildItem $parentFolder -ObjectType job -IgnorePredefined 

    foreach($job in $jobs) {
            
        $thisJob = get-item JD:\$($job.qualifiedName)
        $exportFileName="job_$($thisJob.Name)"

        $jobExportPath = $parentFolder.Replace("JD:", "$ExportDirectory\Definitions")
        if (!(test-path $jobExportPath)){
            New-Item -Path "$jobExportPath" -ItemType Directory
        }
        if($thisJob -ne $null){
            write-host "$jobExportPath$exportFileName.xml"
            Export-JAMSXml -InputObject $thisJob -Path "$jobExportPath\$exportFileName.xml" -IgnoreACL -Server localhost 
        }
    }                     
}
$FullFolderList=$null
$jobs=$null
$vars=$null

$parentFolder = "JD:\"
$rootjobs = Get-ChildItem $parentFolder -ObjectType job -IgnorePredefined
foreach($job in $rootjobs) {
            
    $thisJob = get-item JD:\$($job.qualifiedName)
    $exportFileName="job_$($thisJob.Name)"

    $jobExportPath = $parentFolder.Replace("JD:", "$ExportDirectory\Definitions")
    if (!(test-path $jobExportPath)){
        New-Item -Path "$jobExportPath" -ItemType Directory
    }
    if($thisJob -ne $null){
        write-host "$jobExportPath\$exportFileName.xml"
        Export-JAMSXml -InputObject $thisJob -Path "$jobExportPath\$exportFileName.xml" -IgnoreACL -Server localhost 
    }
}     
$rootjobs=$null

$rootvars = Get-ChildItem $parentFolder -ObjectType variable -IgnorePredefined
foreach($var in $rootvars) {
    $thisVar=$null   
    $thisVar = get-item JD:\$($var.qualifiedName)
    $exportFileName="var_$($thisVar.Name)"

    $varExportPath = $parentFolder.Replace("JD:", "$ExportDirectory\Definitions")
    if (!(test-path $varExportPath)){
        New-Item -Path "$varExportPath" -ItemType Directory
    }
    if($thisVar -ne $null){
        write-host "$varExportPath\$exportFileName.xml"
        Export-JAMSXml -InputObject $thisVar -Path "$varExportPath\$exportFileName.xml" -IgnoreACL -Server localhost 
    }
}
$rootvars=$null

$calendars = Get-ChildItem "JD:\Calendars\*"
#Export calendars
foreach($cal in $calendars){
    
    $calExportPath = "$ExportDirectory\Calendars" #Change export path location

    $thisCal = Get-Item $cal.PSPath
    $exportFileName = $thisCal.Name

    if (!(Test-Path $calExportPath)){
        New-Item -Path "$calExportPath" -ItemType Directory
    }
    if($thisCal -ne $null){
        Write-Host "$calExportPath\$exportFileName.xml"
        Export-JAMSXML -InputObject $thisCal -Path "$calExportPath\$exportFileName.xml" -IgnoreACL -Server localhost
    }
}
$calendars=$null

$agents = Get-ChildItem "JD:\Agents\*"
#Export agents
foreach($agent in $agents){
    
    $agentExportPath = "$ExportDirectory\Agents" #Change export path location
    
    $thisAgent = Get-Item $agent.PSPath
    $exportFileName = ($thisAgent.AgentName).Replace("\","_")

    if (!(Test-Path $agentExportPath)){
        New-Item -Path "$agentExportPath" -ItemType Directory
    }
    if($thisAgent -ne $null){
        Write-Host "$agentExportPath\$exportFileName.xml"
        Export-JAMSXML -InputObject $thisAgent -Path "$agentExportPath\$exportFileName.xml" -IgnoreACL -Server localhost
    }
}
$agents=$null

$credentials = Get-ChildItem "JD:\Credentials\*"
#Export credentials
foreach($cred in $credentials){
    
    $credExportPath = "$ExportDirectory\Credentials" #Change export path location

    $thisCred = Get-Item $cred.PSPath
    $exportFileName = ($thisCred.CredentialName).Replace("\","_")

    if (!(Test-Path $credExportPath)){
        New-Item -Path "$credExportPath" -ItemType Directory
    }
    if($thisCred -ne $null){
        Write-Host "$credExportPath\$exportFileName.xml"
        Export-JAMSXML -InputObject $thisCred -Path "$credExportPath\$exportFileName.xml" -IgnoreACL -Server localhost
    }
}
$credentials=$null

$resources = Get-ChildItem "JD:\Resources\*"
#Export resources
foreach($resource in $resources){
    
    $resourceExportPath = "$ExportDirectory\Resources" #Change export path location

    $thisResource = Get-Item $resource.PSPath
    $exportFileName = $thisResource.ResourceName

    if (!(Test-Path $resourceExportPath)){
        New-Item -Path "$resourceExportPath" -ItemType Directory
    }
    if($thisResource -ne $null){
        Write-Host "$resourceExportPath\$exportFileName.xml"
        Export-JAMSXML -InputObject $thisResource -Path "$resourceExportPath\$exportFileName.xml" -IgnoreACL -Server localhost
    }
}
$resources=$null

$queues = Get-ChildItem "JD:\Queues\*"
#Export queues
foreach($queue in $queues){

    $queueExportPath = "$ExportDirectory\Queues" #Change export path location

    $thisQueue = Get-Item $queue.PSPath
    $exportFileName = $thisQueue.QueueName

    if (!(Test-Path $queueExportPath)){
        New-Item -Path "$queueExportPath" -ItemType Directory
    }
    if($thisQueue -ne $null){
        Write-Host "$queueExportPath\$exportFileName.xml"
        Export-JAMSXML -InputObject $thisQueue -Path "$queueExportPath\$exportFileName.xml" -IgnoreACL -Server localhost
    }
}
$queues=$null

$timeDefs = Get-ChildItem "JD:\Times\*"
#Export time definitions
foreach($timeDef in $timeDefs){

    $timeExportPath = "$ExportDirectory\TimeDefinitions" #Change export path location

    $thisTimeDef = Get-Item $timeDef.PSPath
    $exportFileName = $thisTimeDef.Name

    if (!(Test-Path $timeExportPath)){
        New-Item -Path "$timeExportPath" -ItemType Directory
    }
    if($thisTimeDef -ne $null){
        Write-Host "$timeExportPath\$exportFileName.xml"
        Export-JAMSXML -InputObject $thisTimeDef -Path "$timeExportPath\$exportFileName.xml" -IgnoreACL -Server localhost
    }
}
$timeDefs=$null

$ExecutionMethods = Get-ChildItem JD:\Methods\*
#Export ExecutionMethods
foreach($em in $ExecutionMethods){

    $methodExportPath = "$ExportDirectory\Methods" #Change export path location

    $thisMethod = Get-Item $em.PSPath
    $exportFileName = $thisMethod.Name

    if (!(Test-Path $methodExportPath)){
        New-Item -Path "$methodExportPath" -ItemType Directory
    }
    if($thisMethod -ne $null){
        Write-Host "$methodExportPath\$exportFileName.xml"
        Export-JAMSXML -InputObject $thisMethod -Path "$methodExportPath\$exportFileName.xml" -IgnoreACL -Server localhost
    }
}
$ExecutionMethods=$null
Stop-Transcript