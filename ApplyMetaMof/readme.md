Summary
=======
The `New-DscMetaConfiguration` cmdlet allows you to create a _localhost.meta.mof_ with the options specified when calling the cmdlet. Optionally, it will also apply the the meta configuration (and remove the temporary _localhost.meta.mof_).

How To Run
==========
Dot source the `New-DscMetaConfiguration.ps1` file into your session and run the following:

```powershell
New-DscMetaConfiguration -Path c:\temp\myTemp.mof -ConfigurationMode ApplyOnly -RefreshMode Push -RebootNodeIfNeeded $false -DebugMode None -ActionAfterReboot StopConfiguration -StatusRetentionTimeInDays 30
```

How It Works
============
At it's core, this cmdlet just builds the DSC configuration code to create a _localhost.meta.mof_ file, based on the parameters specified. From there, a meta configuration file can be created, or it can be directly applied.

Future
======
In the near future, we will be packaging this cmdlet into a module and publishing to the PowerShell Gallery.
