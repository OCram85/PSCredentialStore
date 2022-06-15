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
        try {
            Install-Module -Name 'PSScriptAnalyzer' -Scope CurrentUser -RequiredVersion '1.19.1' -Force -SkipPublisherCheck -AllowClobber -Verbose:$VerbosePreference -ErrorAction 'Stop'
            Install-Module -Name 'Pester' -Scope CurrentUser -RequiredVersion '4.10.1' -Force -SkipPublisherCheck -AllowClobber -Verbose:$VerbosePreference -ErrorAction 'Stop'
            Install-Module -Name 'posh-git' -Scope CurrentUser -RequiredVersion '0.7.3' -Force -SkipPublisherCheck -AllowClobber -Verbose:$VerbosePreference -ErrorAction 'Stop'
            Install-Module -Name 'PSCoverage' -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber -RequiredVersion '1.2.108' -Verbose:$VerbosePreference -ErrorAction 'Stop'
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
        }
        Invoke-ScriptAnalyzer @AnalyzerSettings
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
