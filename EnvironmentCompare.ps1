#
# This script will compare two Environments - $SourceServer and $DestServer set below 
# The comparison will list jobs that are newer on the source server and have been modified within the $LastModified number of days (eg, in last 3 days, set $LastModified = -3)
# It will also list any jobs, variables, or folders that are missing from the destination environment, but exist in the source
#
$SourceServer="DF-JAMS7-2"
$DestServer="DF-JAMS7"
$LastModified = -1

Import-Module JAMS
New-PSDrive JDS JAMS $SourceServer #-ErrorAction SilentlyContinue
New-PSDrive JDD JAMS $DestServer #-ErrorAction SilentlyContinue

# Gather List of folders from both environments
$SourceFolders = Get-ChildItem -Path JDS:\ -ObjectType folder -IgnorePredefined -Recurse
$DestFolders = Get-ChildItem -Path JDD:\ -ObjectType folder -IgnorePredefined -Recurse

$MissingFolders = @()
# Find the Matching and Missing Folders
$FolderComparison = Compare-Object -ReferenceObject $SourceFolders -DifferenceObject $DestFolders -Property QualifiedName -IncludeEqual
$MatchingFolders = $FolderComparison | Where-Object {$_.SideIndicator -eq '=='}
$MissingFolders += $FolderComparison | Where-Object {$_.SideIndicator -eq '<='}

ForEach($folder in $MatchingFolders){
    $MissingJobs = @()
    $MissingVariables = @()
    
    write-host "`n#################################################################################################################" -BackgroundColor Black -ForegroundColor Cyan
    $SourcePath = "JDS:$($folder.QualifiedName)"
    $DestPath = "JDD:$($folder.QualifiedName)"
    write-host "Comparing Existing Folder: $($folder.QualifiedName)" -BackgroundColor Black -ForegroundColor Cyan

    #check jobs - then variables
    #Fetch jobs
    $SourceJobs = Get-ChildItem $SourcePath -ObjectType Job -IgnorePredefined -FullObject
    $DestJobs = Get-ChildItem $DestPath -ObjectType Job -IgnorePredefined -FullObject
    
    If($SourceJobs -and $DestJobs){
        #Compare Jobs
        $JobComparison = Compare-Object -ReferenceObject $SourceJobs -DifferenceObject $DestJobs -Property QualifiedName -IncludeEqual

        $MatchingJobs = $JobComparison | Where-Object {$_.SideIndicator -eq '=='}
        $MissingJobs = $JobComparison | Where-Object {$_.SideIndicator -eq '<='}

        if($MatchingJobs){
            #iterate through matching jobs to find any newer
            foreach($job in $MatchingJobs){
              
                $jerb = $SourceJobs | where-object { $_.QualifiedName -eq $job.QualifiedName }
                if($jerb.LastChange -gt (Get-Date).AddDays($LastModified)){
                    $jobDetails = Get-Item "JDD:$($job.QualifiedName)"
            
                    if($jobDetails.LastChange -lt $jerb.LastChange){
                        # want to see if source job is newer
                        write-host $jobDetails.Name "Was recently changed on" $jobDetails.LastChange " By " $jobDetails.LastChangedBy " and is newer on source server" -BackgroundColor Black -ForegroundColor Yellow
                    }
                }
            }
        }
    }ElseIf($SourceJobs){
        write-host "`nMissing Job List: " -BackgroundColor Black -ForegroundColor Cyan
        Write-host "All Jobs are missing from folder: $($folder.QualifiedName)" -BackgroundColor Black -ForegroundColor Red
    }
    if($MissingJobs){
        write-host "`nMissing Jobs List: " -BackgroundColor Black -ForegroundColor Cyan
        Foreach($job in $MissingJobs){
            write-host "Job: $($job.QualifiedName) is missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
        }
    }

    #Fetch Variables
    $SourceVars = Get-ChildItem $SourcePath -ObjectType variable -IgnorePredefined -FullObject
    $DestVars = Get-ChildItem $DestPath -ObjectType variable -IgnorePredefined -FullObject
    
    #Compare Variables
    if($SourceVars -and $DestVars){
        
        $VarComparison = Compare-Object -ReferenceObject $SourceVars -DifferenceObject $DestVars -Property Name -IncludeEqual
        $MatchingVars = $VarComparison | Where-Object {$_.SideIndicator -eq '=='}
        $MissingVariables = $VarComparison | Where-Object {$_.SideIndicator -eq '<='}
    }
    elseif($SourceVars){
        write-host "`nMissing Variable List: " -BackgroundColor Black -ForegroundColor Cyan
        Write-host "All Variables are missing from folder: $($folder.QualifiedName)" -BackgroundColor Black -ForegroundColor Red
    }
    
    # List any missing items not already mentioned
    if($MissingVariables){
        write-host "`nMissing Variable List: " -BackgroundColor Black -ForegroundColor Cyan
        Foreach($var in $MissingVariables){
            write-host "Variable: $($var.Name) is missing from Folder: $($folder.QualifiedName) on $DestServer" -BackgroundColor Black -ForegroundColor Red
        }
    }
    

}
# List any missing items not already mentioned
# Starting with any missing Folders
If($MissingFolders){
    write-host "`nMissing Folder List: " -BackgroundColor Black -ForegroundColor Cyan
    Foreach($folder in $MissingFolders){ #else{   #if($folder.QualifiedName -notin $DestFolders.QualifiedName){
        Write-Host "Folder: $($folder.QualifiedName) is missing from $DestServer along with all it contains." -BackgroundColor Black -ForegroundColor Red
    }
}

# Gather List of Credentials from both environments
$SourceCreds = Get-ChildItem -Path JDS:\Credentials
$DestCreds = Get-ChildItem -Path JDD:\Credentials
If($SourceCreds -and $DestCreds){
    $MissingCreds = @()
    # Find the Missing Credentials
    $CredComparison = Compare-Object -ReferenceObject $SourceCreds -DifferenceObject $DestCreds -Property Name -IncludeEqual
    $MissingCreds = $CredComparison | Where-Object {$_.SideIndicator -eq '<='}
    if($MissingCreds){
        write-host "`nMissing Credentials List: " -BackgroundColor Black -ForegroundColor Cyan
        foreach($cred in $MissingCreds){
            Write-Host "Credential: $($Cred.Name) is missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
        }        
    }
}elseif($SourceCreds){
    write-host "`nMissing Credentials List: " -BackgroundColor Black -ForegroundColor Cyan
    Write-host "All Credentials are missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
}

# Gather List of Agents from both environments
$SourceAgents = Get-ChildItem -Path JDS:\Agents | where-object {$_.AgentType -eq "Outgoing" -or $_.AgentType -eq "SSHAgentX" }
$DestAgents = Get-ChildItem -Path JDD:\Agents | where-object {$_.AgentType -eq "Outgoing" -or $_.AgentType -eq "SSHAgentX" }
if($SourceAgents -and $DestAgents){
    $MissingAgents = @()
    # Find the Missing Agents
    $AgentComparison = Compare-Object -ReferenceObject $SourceAgents -DifferenceObject $DestAgents -Property AgentName -IncludeEqual
    $MissingAgents = $AgentComparison | Where-Object {$_.SideIndicator -eq '<='}
    if($MissingAgents){
        write-host "`nMissing Agent List: " -BackgroundColor Black -ForegroundColor Cyan
        foreach($Agent in $MissingAgents){
            Write-Host "Agent: $($Agent.AgentName) is missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
        }        
    }
}elseif($SourceAgents){
    write-host "`nMissing Agent List: " -BackgroundColor Black -ForegroundColor Cyan
    Write-host "All Agents are missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
}

# Gather List of Connections from both environments
$SourceConns = Get-ChildItem -Path JDS:\Agents | where-object {$_.AgentType -ne "Outgoing" -and $_.AgentType -ne "SSHAgentX" -and $_.AgentType -ne "Local"}
$DestConns = Get-ChildItem -Path JDD:\Agents | where-object {$_.AgentType -ne "Outgoing" -and $_.AgentType -ne "SSHAgentX" }
if($SourceConns -and $DestConns){
    $MissingConns = @()
    # Find the Missing Connections
    $ConnComparison = Compare-Object -ReferenceObject $SourceConns -DifferenceObject $DestConns -Property AgentName -IncludeEqual
    $MissingConns = $ConnComparison | Where-Object {$_.SideIndicator -eq '<='}
    if($MissingConns){
        write-host "`nMissing Connection List: " -BackgroundColor Black -ForegroundColor Cyan
        foreach($Conn in $MissingConns){
            Write-Host "Connection: $($Conn.AgentName) is missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
        }        
    }
}elseif($SourceConns){
    write-host "`nMissing Connections List: " -BackgroundColor Black -ForegroundColor Cyan
    Write-host "All Connections are missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
}

# Gather List of Execution Methods from both environments
$SourceMethods = Get-ChildItem -Path JDS:\Methods
$DestMethods = Get-ChildItem -Path JDD:\Methods
if($SourceMethods -and $DestMethods){
    $MissingMethods = @()
    # Find the Missing Methods
    $MethodComparison = Compare-Object -ReferenceObject $SourceMethods -DifferenceObject $DestMethods -Property Name -IncludeEqual
    $MissingMethods = $MethodComparison | Where-Object {$_.SideIndicator -eq '<='}
    if($MissingMethods){
        write-host "`nMissing Execution Method List: " -BackgroundColor Black -ForegroundColor Cyan
        foreach($Method in $MissingMethods){
            Write-Host "Execution Method: $($Method.Name) is missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
        }        
    }
}elseif($SourceMethods){
    write-host "`nMissing Execution Methods List: " -BackgroundColor Black -ForegroundColor Cyan
    Write-host "All Execution Methods are missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
}

# Gather List of Resources from both environments
$SourceResources = Get-ChildItem -Path JDS:\Resources
$DestResources = Get-ChildItem -Path JDD:\Resources
if($SourceResources -and $DestResources){
    $MissingResources = @()
    # Find the Missing Resources
    $ResourceComparison = Compare-Object -ReferenceObject $SourceResources -DifferenceObject $DestResources -Property Name -IncludeEqual
    $MissingResources = $ResourceComparison | Where-Object {$_.SideIndicator -eq '<='}
    if($MissingResources){
        write-host "`nMissing Resource List: " -BackgroundColor Black -ForegroundColor Cyan
        foreach($Resource in $MissingResources){
            Write-Host "Resource: $($Resource.Name) is missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
        }        
    }
}elseif($SourceResources){
    write-host "`nMissing Resources List: " -BackgroundColor Black -ForegroundColor Cyan
    Write-host "All Resources are missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
}

# Gather List of Queues from both environments
$SourceQueues = Get-ChildItem -Path JDS:\Queues
$DestQueues = Get-ChildItem -Path JDD:\Queues
if($SourceQueues -and $DestQueues){
    $MissingQueues = @()
    # Find the Missing Queues
    $QueueComparison = Compare-Object -ReferenceObject $SourceQueues -DifferenceObject $DestQueues -Property Name -IncludeEqual
    $MissingQueues = $QueueComparison | Where-Object {$_.SideIndicator -eq '<='}
    if($MissingQueues){
        write-host "`nMissing Queue List: " -BackgroundColor Black -ForegroundColor Cyan
        foreach($Queue in $MissingQueues){
            Write-Host "Queue: $($Queue.Name) is missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
        }        
    }
}elseif($SourceQueues){
    write-host "`nMissing Queues List: " -BackgroundColor Black -ForegroundColor Cyan
    Write-host "All Queues are missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
}

# Gather List of Dates from both environments
$SourceDates = Get-ChildItem -Path JDS:\Dates
$DestDates = Get-ChildItem -Path JDD:\Dates
if($SourceDates -and $DestDates){
    $MissingDates = @()
    # Find the Missing Dates
    $DateComparison = Compare-Object -ReferenceObject $SourceDates -DifferenceObject $DestDates -Property Name -IncludeEqual
    $MissingDates = $DateComparison | Where-Object {$_.SideIndicator -eq '<='}
    if($MissingDates){
        write-host "`nMissing Date List: " -BackgroundColor Black -ForegroundColor Cyan
        foreach($Date in $MissingDates){
            Write-Host "Custom DateType: $($Date.Name) is missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
        }        
    }
}elseif($SourceDates){
    write-host "`nMissing Dates List: " -BackgroundColor Black -ForegroundColor Cyan
    Write-host "All Dates are missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
}

# Gather List of Calendars from both environments
$SourceCals = Get-ChildItem -Path JDS:\Calendars 
$DestCals = Get-ChildItem -Path JDD:\Calendars 
if($SourceCals -and $DestCals){
    $MissingCals = @()
    # Find the Missing Calendars
    $CalComparison = Compare-Object -ReferenceObject $SourceCals -DifferenceObject $DestCals -Property Name -IncludeEqual
    $MissingCals = $CalComparison | Where-Object {$_.SideIndicator -eq '<='}
    if($MissingCals){
        write-host "`nMissing Calendar List: " -BackgroundColor Black -ForegroundColor Cyan
        foreach($Cal in $MissingCals){
            Write-Host "Calendar: $($Cal.Name) is missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
        }        
    }
}elseif($SourceCals){
    write-host "`nMissing Calendars List: " -BackgroundColor Black -ForegroundColor Cyan
    Write-host "All Calendars are missing from $DestServer" -BackgroundColor Black -ForegroundColor Red
}

Remove-PSDrive JDS
Remove-PSDrive JDD