<#
.SYNOPSIS
    Generate and optionally apply DSC Local Meta Configuration
.DESCRIPTION
	Generate and optionally apply DSC Local Meta Configuration
.EXAMPLE
    C:\PS> New-DscMetaConfiguration -Apply -ConfigurationMode ApplyOnly -RefreshMode Push -RebootNodeIfNeeded $false -DebugMode None -ActionAfterReboot StopConfiguration -StatusRetentionTimeInDays 30
.EXAMPLE
    C:\PS> New-DscMetaConfiguration -Path c:\temp\mykewlmeta.mof -ConfigurationMode ApplyOnly -RefreshMode Push -RebootNodeIfNeeded $false -DebugMode None -ActionAfterReboot StopConfiguration -StatusRetentionTimeInDays 30
#>
function New-DscMetaConfiguration
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'file')]
        [string]$Path,
        [parameter(Mandatory = $true, Position = 0, ParameterSetName = 'apply')]
        [switch]$Apply,

        [ValidateSet('ContinueConfiguration', 'StopConfiguration')]
        $ActionAfterReboot,
        [string]$CertificateId,
        [ValidateSet('ApplyOnly', 'ApplyAndMonitor', 'ApplyAndAutoCorrect')]
        [string]$ConfigurationMode,
        [int]$ConfigurationModeFrequencyMins,
        [ValidateSet('None', 'ForceModuleImport', 'All')]
        [string]$DebugMode,
        [bool]$RebootNodeIfNeeded,
        [ValidateSet('Disabled', 'Push', 'Pull')]
        [string]$RefreshMode,
        [int]$RefreshFrequencyMins,
        [int]$StatusRetentionTimeInDays
    )

    $params = $PSBoundParameters
    $params.Remove('Path') | Out-Null
    $params.Remove('Apply') | Out-Null

    $metaMofTemplate = @"
[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node localhost
    {
        Settings
        {
            %Settings%
        }
    }
}
"@

    $tabLevelMatch = (($metaMofTemplate -split "`n") | Select-String -Pattern '(\s+)%Settings%')
    $tabLevel = $tabLevelMatch.Matches.Captures.Groups[1].Value
    [string[]]$replacementLines = @()
    foreach($param in $params.GetEnumerator())
    {
        $value = "'$($param.Value)'"
        if($param.Value -is [int])
        {
            $value = "$($param.Value)"
        }
        if($param.Value -is [bool])
        {
            $value = "`$$($param.Value)"
        }
        $replacementLines += "$tabLevel$($param.Key) = $value"
    }

    $metaMof = $metaMofTemplate -replace "$($tabLevelMatch.Matches.Captures.Groups[0].Value)", ($replacementLines -join "`r`n")
    
    $tempRoot = [IO.Path]::GetTempPath()
    $tempFolder = Get-Date -Format FileDateTime
    $tempPath = Join-Path -Path $tempRoot -ChildPath $tempFolder
    New-Item -Path $tempRoot -Name $tempFolder -ItemType Directory | Out-Null
    Write-Verbose 'Generating DSC meta configuration...'
    Push-Location
    Set-Location $tempPath
    Invoke-Expression $metaMof 
    LCMConfig | Out-Null

    if($PSCmdlet.ParameterSetName -eq 'file')
    {
        Write-Verbose "Writing DSC meta configuration to $Path..."
        Copy-Item -Path "$tempPath\LCMConfig\localhost.meta.mof" -Destination $Path | Out-Null
        Pop-Location
        Remove-Item -Path $tempPath -Recurse -Force | Out-Null
        return Get-Item -Path $Path
    }

    if($PSCmdlet.ParameterSetName -eq 'apply')
    {
        Write-Verbose 'Applying DSC meta configuration...'
        Set-DscLocalConfigurationManager -Path "$tempPath\LCMConfig"
        Pop-Location
        Remove-Item -Path $tempPath -Recurse -Force | Out-Null        
    }
}