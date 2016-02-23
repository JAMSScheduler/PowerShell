JAMSEX
==========

This module serves to hold additional cmdlets that do not yet fit their own category. Some are related to file handling and monitoring, others specific to JAMS

To utilize, ensure JAMSEX.psm1 is saved into a folder caled JAMSEX in the root install directory of the JAMS Module(s), by default found here: C:\Program Files\MVPSI\Modules

Additionally, you can utilize the module as Windows Workflow Activities within JAMS, by storing the WFToolbox.JAMSEX.config file within the JAMS Client folder, by default found here: C:\Program Files\MVPSI\JAMS\Client

cmdlets
==========
* Wait-File
* Remove-JAMSObjects
* Test-JAMSAgent
* Set-JAMSPermission

Descriptions
==========
```
.Synopsis
   Wait for the specified files
.DESCRIPTION
   Wait for the specified files to appear and optionally, to be available.
.EXAMPLE
   WaitFor-File Xyzzy.dat
.EXAMPLE
   WaitFor-File *.txt
   
.Synopsis
   Deletes all objects in a JAMS Folder
.DESCRIPTION
   Deletes all objects in a JAMS Folder including subfolders.
.EXAMPLE
   Remove-AllJAMSObjects JAMS::localhost\Folder1\Folder2\
.EXAMPLE
   Remove-AllJAMSObjects JAMS::localhost\Folder1\Folder2\ -Verbose

.Synopsis
   Will test if an Agent is currently online or offline
.DESCRIPTION
   Will return Online or Offline for the status of a JAMS Agent running on Windows or Linux
.EXAMPLE
   $AgentStatus = Test-JAMSAgent -Name SQLAgent1
.EXAMPLE
   $AgentStatus = Test-JAMSAgent -Name SQLAgent1 -Server MVPJAMSProd

.Synopsis
   Set permissions on JAMS folders
.DESCRIPTION
   Allows you to programmatically set and define permissions to JAMS Folders
.EXAMPLE
   Set-JAMSPermission -folderName 'Samples' -abort $true -addJobs $true -change $true -changeJobs $true -control $true -debugPerm $true -delete $true -deleteJobs $true -inquire $true -inquireJobs $true -manage $true -monitor $true -submit $true -user 'MVP\Admins'
.EXAMPLE
   Set-JAMSPermission -folderName 'Samples' -abort $false -addJobs $false -change $false -changeJobs $false -control $false -debugPerm $false -delete $false -deleteJobs $false -inquire $true -inquireJobs $true -manage $false -monitor $true -submit $false -user 'MVP\Readers'
```
