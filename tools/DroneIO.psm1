$Global:ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

function Invoke-ShowEnv {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSProvideCommentHelp',
        '',
        Justification = 'internal function'
    )]
    param ()

    process {
        Get-ChildItem -Path 'Env:' | Format-Table | Out-String
    }
}

function Invoke-InstallDependencies {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSProvideCommentHelp',
        '',
        Justification = 'internal function'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseSingularNouns',
        '',
        Justification = 'internal function'
    )]
    param ()

    process {
        $ErrorActionPreference = 'Stop'
        try {
            $ParamsPSScript = @{
                Name               = 'PSScriptAnalyzer'
                Scope              = 'CurrentUser'
                RequiredVersion    = '1.20.0'
                Force              = $true
                SkipPublisherCheck = $true
                AllowClobber       = $true
                Verbose            = $VerbosePreference
            }
            Install-Module @ParamsPSScript

            $ParamsPester = @{
                Name               = 'Pester'
                Scope              = 'CurrentUser'
                RequiredVersion    = '5.3.3'
                Force              = $true
                SkipPublisherCheck = $true
                AllowClobber       = $true
                Verbose            = $VerbosePreference
            }
            Install-Module @ParamsPester

            $ParamsPosh = @{
                Name               = 'posh-git'
                Scope              = 'CurrentUser'
                RequiredVersion    = '1.1.0'
                Force              = $true
                SkipPublisherCheck = $true
                AllowClobber       = $true
                Verbose            = $VerbosePreference
                #ErrorAction = 'Stop'
            }
            Install-Module @ParamsPosh
        }
        catch {
            $ExceParams = @{
                Exception   = [System.Exception]::new(
                    'Could not install required build dependencies!',
                    $PSItem.Exception
                )
                ErrorAction = 'Stop'
            }
            Write-Error @ExceParams
        }

    }
}

function Invoke-Linter {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSProvideCommentHelp',
        '',
        Justification = 'internal function'
    )]
    param ()

    process {
        Import-Module -Name PSScriptAnalyzer
        $AnalyzerSettings = @{
            Path          = './src/'
            Recurse       = $true
            Settings      = './tools/PSScriptAnalyzerSettings.psd1'
            ReportSummary = $true
            ErrorAction   = 'Stop'
        }
        try {
            $AnalyzerResults = Invoke-ScriptAnalyzer @AnalyzerSettings
            if ( $AnalyzerResults ) {
                $AnalyzerResults | Sort-Object -Property @(
                    "ScriptName",
                    "Line"
                ) | Format-Table @(
                    "Severity",
                    "ScriptName",
                    "Line",
                    "RuleName",
                    "Message"
                ) -AutoSize | Out-String | Write-Verbose -Verbose
            }
        }
        catch {
            Write-Debug -Message $_.Exception.Message -Debug
            Write-Error -Message 'PSScriptAnalyzer failer'
        }
    }
}

function Invoke-UnitTest {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSProvideCommentHelp',
        '',
        Justification = 'internal function'
    )]

    param (
        [Parameter( Mandatory = $false )]
        [ValidateSet('JaCoCo', 'CoverageGutters')]
        [string]$CoverageFormat = 'JaCoCo',

        [Parameter(Mandatory = $false)]
        [ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
        [string]$Verbosity = 'Normal',

        [Parameter(Mandatory = $false)]
        [switch]$PassThru,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Tag,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ExcludeTag
    )

    process {
        Write-Verbose -Message '===== Running Pester =====' -Verbose:$VerbosePreference
        $PesterConf = New-PesterConfiguration
        $PesterConf.Run.Path = (Resolve-Path -Path './src').Path
        $PesterConf.Run.Exit = $false
        $PesterConf.Run.PassThru = $true
        $PesterConf.CodeCoverage.Enabled = $true
        $PesterConf.CodeCoverage.OutputFormat = $CoverageFormat
        $PesterConf.TestResult.Enabled = $true
        $CovFiles = Get-ChildItem -Path "./src/*.ps1" -Recurse | Where-Object {
            $_.BaseName -notmatch '.Tests'
        } | Select-Object -ExpandProperty 'FullName'
        $PesterConf.CodeCoverage.Path = $CovFiles
        $PesterConf.Output.Verbosity = $Verbosity
        # Set Tags if given
        if ($Tag) {
            $PesterConf.Filter.Tag = $Tag
        }
        if ($ExcludeTag) {
            $PesterConf.Filter.ExcludeTag = $ExcludeTag
        }
        $TestResults = Invoke-Pester -Configuration $PesterConf -ErrorAction 'Stop'
        if ($PassThru.IsPresent) {
            Write-Output -InputObject $TestResults
        }
    }
}
