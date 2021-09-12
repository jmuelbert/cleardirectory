@{
    PSDependOptions     = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }

    InvokeBuild         = 'latest'
    PSScriptAnalyzer    = 'latest'
    Pester              = '4.10.1'
    Plaster             = 'latest'
    ModuleBuilder       = 'latest'
    MarkdownLinkCheck   = 'latest'
    ChangelogManagement = 'latest'
    Sampler             = 'latest'

}

