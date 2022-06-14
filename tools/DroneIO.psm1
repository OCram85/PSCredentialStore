$Global:ProgressPreference = 'SilentlyContinue'

function Invoke-ShowEnv {
    [CmdletBinding()]
    param ()

    process {
        Get-ChildItem -Path 'Env:' | Format-Table | Out-String
    }
}

function Invoke-InstallDependencies {
    [CmdletBinding()]
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
    param ()

    process {
        Invoke-ScriptAnalyzer -Path './src/' -Recurse
    }
}

function Invoke-UnitTests {
    [CmdletBinding()]
    param ()

    process {
        try {
            Write-Host '===== Preload internal private functions =====' -ForegroundColor Black -BackgroundColor Yellow

            $Privates = Get-ChildItem -Path (Join-Path -Path $Env:DRONE_WORKSPACE -ChildPath '/src/Private/*') -Include "*.ps1" -Recurse -ErrorAction Stop
            foreach ($File in $Privates) {
                if (Test-Path -Path $File.FullName) {
                    . $File.FullName
                    Write-Verbose -Message ('Private function dot-sourced: {0}' -f $File.FullName) -Verbose
                }
                else {
                    Write-Warning -Message ('Could not find file: {0} !' -f $File.FullName)
                }
            }
        }
        catch {
            $_.Exception.Message | Write-Error
            throw 'Could not load required private functions!'
        }

        Write-Host '===== Running Pester =====' -ForegroundColor Black -BackgroundColor Yellow
        $srcFiles = Get-ChildItem -Path "./src/*.ps1" -Recurse | Sort-Object -Property 'Name' | Select-Object -ExpandProperty 'FullName'
        $TestFiles = Get-ChildItem -Path (Join-Path -Path '.' -ChildPath './tests/*.Tests.ps1') -Recurse | Sort-Object -Property Name
        $TestResults = Invoke-Pester -Path $testFiles -CodeCoverage $srcFiles -PassThru -CodeCoverageOutputFile "./coverage.xml" -CodeCoverageOutputFileEncoding ascii -CodeCoverageOutputFileFormat JaCoCo

        if ($TestResults.FailedCount -gt 0) {
            throw ('{0} tests failed!' -f $TestResults.FailedCount)
        }
    }
}
