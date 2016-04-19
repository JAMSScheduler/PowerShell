### Import JAMS Module
Import-Module JAMS

### Create the JAMS Drive
New-PSDrive JD JAMS JAMSServerName

### Get Jobs and Setups
$jobs = Get-ChildItem JD:\ -Recurse -IgnorePredefined -ObjectType job
$setups = Get-ChildItem JD:\ -Recurse -IgnorePredefined -ObjectType Setup

### Loop through each job, if a job references a Variable give us the reference information
ForEach($job in $jobs){


    $params = $job.Parameters
    ForEach($param in $params){
    
        If($param.VariableName){
        
        
            Write-Host "Found Variable Reference in Job: "$job.QualifiedName
            Write-Host "Parameter: "$param.ParamName
            Write-Host "Variable Reference: "$param.VariableName
            Write-Host ""
        
        }
        

    
    }
    

}

### Loop through each setup, loop through each setup job, if the setup job parameter contains a variable reference, give us the reference information
ForEach($setup in $setups){


    $sjobs = $setup.Jobs
    ForEach($sjob in $sjobs){
    
      
            $sjparams = $sjob.Parameters
            ForEach($sjparam in $sjparams){
                
                If($sjparam.VariableName){
            
        
                    Write-Host "Found Variable Reference in Setup: "$setup.QualifiedName
                    Write-Host "Found Variable Reference in SetupJob: "$sjob.Name
                    Write-Host "Parameter: "$sjparam.ParamName
                    Write-Host "Variable Reference: "$sjparam.VariableName
                    Write-Host ""
        
            }
        
        }
        

    
    }
    

}
