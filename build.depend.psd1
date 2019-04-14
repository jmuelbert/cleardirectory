@{
    PSDependOptions  = @{
        Target    = '$DependencyPath/_build-cache/'
        AddToPath = $true
    }
    InvokeBuild      = 'latest'
    PSDeploy         = 'latest'
    BuildHelpers     = 'latest'
    PSScriptAnalyzer = 'latest'
    Pester           = @{
        Version = 'latest'
    }
}
