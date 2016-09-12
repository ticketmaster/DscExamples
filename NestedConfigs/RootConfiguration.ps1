$pref = $VerbosePreference
$VerbosePreference = 'continue'

Configuration RootConfiguration
{
    # Get all ps1 files in the current folder except this one
    $configsToProcess = Get-ChildItem -Path "$($PSScriptRoot)\Configurations" -Filter '*.ps1' 

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration' # Import statements must go in the central/root configuration

    # Start going over each node
    Node $AllNodes.NodeName
    {
        foreach($config in $configsToProcess)
        {
            Write-Verbose "Processing sub-configuration $($config.BaseName)..."
            . "$($config.FullName)" # Import script
            . "$($config.BaseName)" -Node $Node # Invoke configuration
            Write-Verbose "Finished processing sub-configuration $($config.BaseName)."
        }
    }
}

$data = @{ AllNodes = 
    @(
        @{ NodeName = 'test1'; Roles = 'web'; Property1 = $true },
        @{ NodeName = 'test2'; Roles = 'web'; Property1 = $false },
        @{ NodeName = 'test3'; Roles = 'db'; Property1 = $true }
    )}

RootConfiguration -ConfigurationData $data -OutputPath "$PSScriptRoot\Output"
$VerbosePreference = $pref