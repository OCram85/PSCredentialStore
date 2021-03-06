@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'PSCredentialStore.psm1'

    # Version number of this module.
    ModuleVersion        = '0.0.9999'

    # Supported PSEditions
    CompatiblePSEditions = 'Desktop', 'Core'

    # ID used to uniquely identify this module
    GUID                 = '6800e192-9df8-4e30-b253-eb2c799bbe84'

    # Author of this module
    Author               = 'OCram85'

    # Company or vendor of this module
    CompanyName          = ''

    # Copyright statement for this module
    Copyright            = '(c) 2020 OCram85. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'A simple credential manager to store and reuse multiple credential objects.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess     = @(
        'Formats/PSCredential.Store.Format.ps1xml',
        'Formats/PSCredentialStore.Certificate.Attribute.ps1xml'
    )

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @(
        # Certificate
        'Get-CSCertificate',
        'Import-CSCertificate',
        'New-CSCertAttribute',
        'New-CSCertificate',
        'Test-CSCertificate',
        'Use-CSCertificate',
        # Pfx Certificate
        # 'Get-CSPfxCertificate',
        # 'Import-CSPfxCertificate',
        # 'Test-CSPfxCertificate',
        # Connection
        'Connect-To',
        'Disconnect-From',
        'Test-CSConnection',
        # Item
        'Get-CredentialStoreItem',
        'New-CredentialStoreItem',
        'Remove-CredentialStoreItem',
        'Set-CredentialStoreItem',
        'Test-CredentialStoreItem',
        # Store
        'Get-CredentialStore',
        'New-CredentialStore',
        'Test-CredentialStore'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = '*'

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @()

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = 'CredentialStore', 'CredentialManager'

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/OCram85/PSCredentialStore/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/OCram85/PSCredentialStore'

            # A URL to an icon representing this module.
            IconUri      = 'https://raw.githubusercontent.com/OCram85/PSCredentialStore/master/assets/logo256.png'

            # ReleaseNotes of this module
            ReleaseNotes = 'See https://github.com/OCram85/PSCredentialStore/releases page for details.'

            # Prerelease string of this module
            #Prerelease   = 'preview'

            # Flag to indicate whether the module requires explicit user acceptance for install/update
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    HelpInfoURI          = 'https://github.com/OCram85/PSCredentialStore'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}
