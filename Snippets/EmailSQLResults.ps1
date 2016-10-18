

Import-Module SQLPS
$MyQuery = "EXEC sp_who"
$results = Invoke-Sqlcmd -Query $MyQuery -ServerInstance .\SQLExpress -Database JAMS | Format-table | Out-String
Send-MailMessage -To DanielS@mvpsi.com -From DanielS@mvpsi.com -SmtpServer Berry -Body $results -Subject "My SQL query"
