JAMSSQL
==========

This module is for all MS SQL related cmdlets within JAMS.

To utilize, ensure JAMSSQL.psm1 is saved into a folder caled JAMSSQL in the root install directory of the JAMS Module(s), by default found here: C:\Program Files\MVPSI\Modules

Additionally, you can utilize the module as Windows Workflow Activities within JAMS, by storing the WFToolbox.JAMSEX.config file within the JAMS Client folder, by default found here: C:\Program Files\MVPSI\JAMS\Client

cmdlets
==========
* New-JAMSSQLDependency

Descriptions
==========
```
.Synopsis
   Wait for a specific change within a SQL Database
.DESCRIPTION
   Wait for a change within a specified SQL Table and Column within a Database
.EXAMPLE
   New-JAMSSQLDependency -Server "(local)\sqlexpress" -Database OurDB -Table Customers -Column ID -NewValue 15
.EXAMPLE
   New-JAMSSQLDependency -Server "(local)\sqlexpress" -Database JAMS -Table CurJob -Column cur_job -NewValue Process2
```
