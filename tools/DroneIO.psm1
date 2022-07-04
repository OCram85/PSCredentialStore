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


function Start-PSScriptAnalyzer {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'justification'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSProvideCommentHelp',
        '',
        Justification = 'internal function'
    )]
    param ()

    process {
        $AnalyzerSettings = @{
            Path          = './src/'
            Recurse       = $true
            Settings      = './tools/PSScriptAnalyzerSettings.psd1'
            ReportSummary = $true
            ErrorAction   = 'Stop'
        }
        $AnalyzerResults = Invoke-ScriptAnalyzer @AnalyzerSettings
        if ( $AnalyzerResults ) {
            Write-Output -InputObject $AnalyzerResults
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
        try {
            $AnalyzerResults = Start-PSScriptAnalyzer
        }
        catch {
            Write-Debug -Message $_.Exception.Message -Debug
            if ($_.Exception.Message -match 'Object reference not set') {
                Write-Debug -Message 'ReRun PSScriptAnalyzer' -Debug
                $AnalyzerResults = Start-PSScriptAnalyzer
            }
            else {
                Write-Error -Message 'PSScriptAnalyzer failer'
            }
        }
        finally {
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
                Update-BuildStateFile
                throw 'PS Script Analyzer failed!'
            }
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

        if ($TestResults.FailedCount -gt 0) {
            Update-BuildStateFile
            throw ('{0} tests failed!' -f $TestResults.FailedCount)
        }

        if ($PassThru.IsPresent) {
            Write-Output -InputObject $TestResults
        }
    }
}

function Update-BuildStateFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$StepName = $Env:DRONE_FAILED_STEPS
    )

    process {
        $StateFilePath = Join-Path -Path $PWD -ChildPath './STATE.xml'
        if (Test-Path -Path $StateFilePath) {
            $StateContent = Import-Clixml -Path $StateFilePath
            $StateContent.Steps += $StepName
        }
        else {
            $StateContent = [PSCustomObject]@{
                Steps = @($StepName)
            }
        }
        Export-Clixml -Path $StateFilePath -InputObject $StateContent -Force -Encoding utf8NoBOM
    }
}

function Invoke-BuildState {
    [CmdletBinding()]
    param ()

    process {
        $StateFilePath = Join-Path -Path $PWD -ChildPath './STATE.xml'
        if ( Test-Path -Path $StateFilePath ) {
            throw 'One one more pipeline steps failed. Marking the pipeline as failed!'
        }
    }
}
