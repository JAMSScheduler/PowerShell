<#
.Synopsis
   Wait for a specific change within a SQL Database
.DESCRIPTION
   Wait for a change within a specified SQL Table and Column within a Database
.EXAMPLE
   New-JAMSSQLDependency -Server "(local)\sqlexpress" -Database OurDB -Table Customers -Column ID -NewValue 15
.EXAMPLE
   New-JAMSSQLDependency -Server "(local)\sqlexpress" -Database JAMS -Table CurJob -Column cur_job -NewValue Process2
#>
function New-JAMSSQLDependency
{
    [CmdletBinding(DefaultParameterSetName='FileSpec', 
                  SupportsShouldProcess=$false, 
                  PositionalBinding=$false,
                  HelpUri = 'http://support.JAMSScheduler.com/',
                  ConfirmImpact='None')]
    [OutputType([System.IO.FileSystemInfo])]
    Param
    (
        # Specify the SQL Server Instance
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Server')]
        [ValidateNotNullOrEmpty()]
        $Server,

        # -Database is used to specify the specific Database we'll be querying
        [Parameter(Mandatory=$true,
                   ParameterSetName='Server')]
        [ValidateNotNullOrEmpty()]
        $Database,

        # -Table is used to specify the specific Table we'll be querying
        [Parameter(Mandatory=$true,
                   ParameterSetName='Server')]
        [ValidateNotNullOrEmpty()]
        $Table,

        # -Column is used to specify the specific column in the table we'll be querying
        [Parameter(Mandatory=$true,
                   ParameterSetName='Server')]
        [ValidateNotNullOrEmpty()]
        $Column,

        # -Value is used to specify the expected new value within the database we're waiting for
        [Parameter(Mandatory=$true,
                   ParameterSetName='Server')]
        [ValidateNotNullOrEmpty()]
        $NewValue,

        # -Timeout can be used to specify the maximum amount of time to wait
        [Parameter(ParameterSetName='Server')]
        [TimeSpan]
        $timeout="0.08:00",

        # -Interval can be used to adjust the delay between checking for the Table/Column updating. The default is 10 seconds.
        [Parameter(ParameterSetName='Server')]
        [int]
        $interval=10
    )

    Begin
    {
        Write-Verbose "Started waiting for SQL $Table at $(Get-Date -format 'u')"
        Write-Verbose "Timeout is set to $timeout"
        $absoluteTimeout = Get-Date 
    }
    Process
    {
        $duration = 0
        $timeoutSeconds = $timeout.TotalSeconds
        $weHaveMatch = $false
        
        Write-Verbose "Waiting for an update to $Table in $Column that match: $NewValue"

        do
        {
            $Modules = Get-Module

            if ($Modules.Name -contains "SQLPS") {
                Write-Verbose "SQLPS Module already loaded..."
            }
            else {
                Write-Verbose "Loading the SQLPS Module..."

                Import-Module SQLPS -WarningAction SilentlyContinue -ErrorVariable SQLModError

                foreach ($err in $SQLModError) {
                    Write-Error $err
                }
            }

            # Run the query and capture any result
            $return = Invoke-Sqlcmd -ServerInstance "$Server" -Database $Database -Query "SELECT $Column FROM $Table"
            Write-Verbose "Checking for $NewValue in database $Database to table $Table in column $Column"
            
	        #
	        # If the query returned a result check if it contains $NewValue
            #
	        if($return -AND $return.ItemArray.Contains($NewValue))
            {
                Write-Verbose "$NewValue has been found."
        	    $weHaveMatch = $true
            }
            else
            {
                #
                # Check if we've exceeded the timeout
                #
                if ($duration -gt $timeoutSeconds)
                {
                    throw "Timeout while waiting for files"
                }

                # Wait the specified interval
                Write-Verbose "Waiting $interval seconds to check again."
                Start-Sleep -seconds $interval

                $duration += $interval
            }
        }
        while(-not $weHaveMatch)
     }
    End{}
} 
