Import-Module JAMS
Import-Module SQLPS

#
#  Execute a SQL query to get a list of open orders
#
$query = @"
SELECT o.order_id,
       o.customer_id
  FROM dbo.Orders o
  where
      o.order_status = 'Open'
"@
$openOrders = Invoke-SqlCmd localhost\SQLExpress -database SampleDB -Sql $query

#
#  Initialize an array to hold all of the jobs that we are about to submit
#
$processEntries = @()

#
#  Submit a job for each open order
#
foreach($order in $openOrders)
{
    #
    #  The job that we submit (ProcessOrder) has a parameter named "id" 
    #  and a parameter named customer_id.  We set the varaiables and
    #  submit with the -UseVariables parameter to make that match
    #
    $id = $order.order_id
    $customer_id = $order.customer_id
    $submitResult = Submit-JAMSEntry ProcessOrder -UseVariables

		#
    #  Add the JAMSEntry number to the array
    #
    $processEntries += $submitResult.JAMSEntry
}

#
#  Wait for all of the jobs we submitted to complete
#
Wait-JAMSEntry $processEntries -verbose

#
#  Now, check the status of each entry
#
foreach($entry in $processEntries)
{
    $entryInfo = Get-JAMSEntry -Entry $entry
    write-host "Final status of entry " $entryInfo.JAMSEntry "is" $entryInfo.FinalStatus
}