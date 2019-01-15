$Global:ProgressPreference = 'SilentlyContinue'

$CALLSIGN = 'PSCredentialStore'
Write-Host ("Callsign is: {0}" -f $CALLSIGN) -ForegroundColor Black -BackgroundColor Yellow

function Invoke-InstallDependencies {
    [CmdletBinding()]
    Param()

    process {
        try {
            Write-Host '===== Environment Vars: =====' -ForegroundColor Black -BackgroundColor Yellow
            Get-ChildItem -Path Env:

            Write-Host -Message '===== Existing Variables: =====' -ForegroundColor Black -BackgroundColor Yellow
            Get-Variable -Name * | Format-Table -AutoSize

            Get-PackageProvider -ListAvailable
            Import-PackageProvider -Name 'NuGet' -MinimumVersion '2.8.5.208' -Verbose -Force

            Install-Module -Name 'Pester' -Scope CurrentUser -RequiredVersion '4.4.2' -Force -SkipPublisherCheck -AllowClobber -Verbose
            Install-Module -Name 'posh-git' -Scope CurrentUser -RequiredVersion '1.0.0-beta2' -Force -SkipPublisherCheck -AllowClobber -AllowPrerelease -Verbose

            Import-Module -Name 'Pester', 'posh-git' -Verbose
        }
        catch {
            $_.Exception.Message | Write-Error
            throw 'Could not install the required dependencies!'
        }
    }
}

function Invoke-UnitTests {
    [CmdletBinding()]
    Param()

    process {

        try {
            Write-Host '===== Preload internal private functions =====' -ForegroundColor Black -BackgroundColor Yellow

            $Privates = Get-ChildItem -Path (Join-Path -Path $Env:TRAVIS_BUILD_DIR -ChildPath '/src/Private/*') -Include "*.ps1" -Recurse
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
        $TestFiles = Get-ChildItem -Path (Join-Path -Path '.' -ChildPath './tests/*.Tests.ps1') -Recurse| Sort-Object -Property Name
        $TestResults = Invoke-Pester -Script $TestFiles -ExcludeTag 'Disabled' -PassThru

        if ($TestResults.FailedCount -gt 0) {
            throw ('{0} tests failed!' -f $TestResults.FailedCount)
        }
    }
}
