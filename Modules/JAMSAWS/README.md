JAMSAWS
==========

This module provides automation between JAMS and Amazon EC2.

To utilize, ensure JAMSAWS.psm1 saved into a folder caled JAMSAWS in the root install directory of the JAMS Module, by default found here: C:\Program Files\MVPSI\Modules

Additionally, you can utilize the module as Windows Workflow Activities within JAMS, by storing the WFToolbox.JAMSAWS.config file within the JAMS Client folder, by default found here: C:\Program Files\MVPSI\JAMS\Client

cmdlets
==========
* Start-JAMSEC2
* Stop-JAMSEC2
* Connect-JAMSAWSLogin
* Wait-ForS3Item
* Submit-JAMSJobOnEC2Tag
 
Descriptions
==========
.Synopsis
   Start a list of your Amazon EC2 instances defined within a CSV file
.DESCRIPTION
   Used in conjunction with the Connect-JAMSAWSLogin cmdlet to parse a CSV file for a list of Amazon EC2 instances, check their status, start any that are offline, boot them up and then grab their Public IP address to be added to a Batch Queue.
.SYNTAX
   Start-JAMSEC2 -InputFile <String> -QueueName <String> -JobLimit <Int32> -StoredCredentials <String>
.EXAMPLE
   Start-JAMSEC2 -InputFile C:\AmazonEC2Instances.csv -QueueName AmazonEC2SQL -JobLimit 25 -StoredCredentials $AmazonAWS

.Synopsis
   Stop a list of your Amazon EC2 instances defined within a CSV file
.DESCRIPTION
   Used in conjunction with the Connect-JAMSAWSLogin cmdlet to parse a CSV file for a list of Amazon EC2 instances, check their status and turn off any running instances.
.SYNTAX
   Stop-JAMSEC2 -InputFile <String> -StoredCredentials <String>
.EXAMPLE
   Stop-JAMSEC2 -InputFile C:\AmazonEC2Instances.csv -StoredCredentials $AmazonAWS

.Synopsis
   Connect to your instance of Amazon AWS
.DESCRIPTION
   Connect and store an Amazon AWS Session into a PowerShell variable utilizing a stored JAMS User
.SYNTAX
   Connect-JAMSAWSLogin -JAMSCredential AmazonAWSLogin -SessionName AmazonAWS
.EXAMPLE
   $AmazonAWS = Connect-JAMSAWSLogin -JAMSCredential AmazonAWSLogin -SessionName AmazonAWS

.Synopsis
   Wait for the specified files
.DESCRIPTION
   Wait for the specified files and folders to become Present, Absent or Modified
.EXAMPLE
   Wait-ForS3Item -Bucket DBBackup -Item SQLServer1.bak -BasedUpon Present -JAMSCredential SQLServerAdmin
.EXAMPLE
   Wait-ForS3Item -Bucket DBBackup -Item DailyArchive -BasedUpon Absent -JAMSCredential SQLServerAdmin -IsFolder

.Synopsis
   Submit JAMS Jobs to run on EC2 Instances matching a Tag
.DESCRIPTION
   Used in conjunction with the Connect-JAMSAWSLogin cmdlet to Submit, Schedule or Hold a Job based upon EC2 Instances with a matching Tag
.SYNTAX
   Submit-JAMSJobOnEC2Tag -Tag ActiveMQ -JAMSJob ServiceRelay -RunAs RHRootML -Region 'us-east-1' -StoredCredentials $AWS
.EXAMPLE
   Submit-JAMSJobOnEC2Tag -Tag JAMSDataLD -JAMSJob ReportBatch -RunAs centos -Region 'us-west-2' -StoredCredentials $AWSSession -SubmitHeld -Verbose

