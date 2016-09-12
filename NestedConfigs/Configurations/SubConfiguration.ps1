# Must be same as filename
Configuration SubConfiguration
{
    param
    (
        [Hashtable]$Node
    )

    Write-Verbose "Verbose output from SubConfiguration.ps1"

    File Test1
    {
        SourcePath = 'C:\test.txt'
        DestinationPath = 'C:\test2.txt'
        Ensure = 'Present'
    }

    # If the node is not a 'web' role server, then do not run anything after the next line
    # (it won't be added to the MOF file)
    if($Node.Roles -notcontains 'web') { return }

    File Test2
    {
        SourcePath = 'C:\test10.txt'
        DestinationPath = 'C:\test12.txt'
        Ensure = 'Present'
    }
}