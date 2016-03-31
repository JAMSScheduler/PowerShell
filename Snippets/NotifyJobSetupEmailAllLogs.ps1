### Powershell Code Snippet to get all job logs from setup jobs in a setup, and email them when the setup completes.
### The script is dependent upon assigning this job as a notification job to the setup, and also the setup must be configured to 
### notify, otherwise the notification job will not run.

### Import JAMS module
Import-Module JAMS

### Get the initatiorID of the setup and search for all jobs with that initiator ID that came from a setup
$initiatorID = "<<JAMS_NOTIFY_JAMS_ENTRY>>"
$jobslist = Get-JAMSEntry | Where-Object {$_.InitiatorID -eq $initiatorID -and $_.InitiatorType -eq "Setup"}

### Initialize an array to hold the job log file names
$files = @()

### Loop through each job in the job list and get each file name, adding the file name to the array
ForEach($job in $jobslist){

    $joblog = $job.LogFileName
    $files += $joblog

}
### Write out all job log file locations in Notification Job log
Write-Host "Sending Job Logs..."
$files

### Send the email with the array of file names as the attachment, customize your email parameters
$to = "Gennarop@mvpsi.com"
$from = "gennarop@mvpsi.com"
$body = "Setup <<JAMS_NOTIFY_JOB_NAME>> has completed."
$smtp = "berry"
$subject = "TestNotification"

Send-MailMessage -to $to -Subject $subject -Attachments $files -Body $body -From gennarop@mvpsi.com -SmtpServer Berry -Verbose
