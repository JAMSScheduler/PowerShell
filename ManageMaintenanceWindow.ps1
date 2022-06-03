
$resource = Get-Item JAMS::localhost\Resources\"MaintenanceWindow"
$resource.QuantityAvailable = 0
$resource.Update()


Start-sleep 600

$resource = Get-Item JAMS::localhost\Resources\"MaintenanceWindow"
$resource.QuantityAvailable = 999999
$resource.Update()

