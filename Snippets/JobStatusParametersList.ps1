# Specify an Entry Number
#
$EntryNumber = <<JAMS_PRECHECK_ENTRY>>
#
# Output the Entry Number so we can check it is what is expected. 
#
Write-host "Checking for entry" $EntryNumber
#
# Get the JAMS Entry 
#
$entry = Get-JAMSEntry $EntryNumber  -server localhost
#
# Get the Parameters set on that Entry
#
$params = $entry.Parameters 
#
# Output the Parameters 
#
$params | Ft JAMSEntry,Name,Value,Datatype
#
# Build the Status
#
$msg = ($params.GetEnumerator() | % { "$($_.ParamName) $($_.Value )" }) -join ' | '
#
# Output the Status Message so we can check it
#
Write-Host "How the status should look for entry" $EntryNumber
write-host $msg 
#
# Set the JAMS Entry on the Entry 
#
Set-JAMSStatus -Entry $EntryNumber -Status $msg -server localhost