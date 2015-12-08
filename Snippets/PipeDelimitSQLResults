### Powershell Snippet using Invoke-Sqlcmd to take the results of a SQL query and pipe delimit the results.  This will omit any fields with a null or whitespace value.

### Import the SQLPS module, it is available as a component install for SQL 2012 and above.
Import-Module SQLPS

### Define array to store results
$STR = @()

### Perform Query, this implies that the SQLPS module is installed
$Exec = Invoke-Sqlcmd -ServerInstance "(local)\Sqlexpress" -Database "JAMS" -Query "exec dbo.FindJobs @folder_path='\Demo', @folder_id='12', @job_name='SlaCalc', @recursive='1'"

# Iterate the returned data row(s)
$Exec | foreach {
    # Iterate each field in the current row
    foreach($fieldVal in $_.ItemArray)
    {
        # Ignore values that are null or whitespace
        if(![String]::IsNullOrWhiteSpace($fieldVal))
        {
            # Add the value to the 
            $STR += $fieldVal
        }
    }

}

# Join all the elements
$STR = $STR -join "|"

Write-Host $STR

$Str = $null
