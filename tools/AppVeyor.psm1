<#
    Define the callsign of you PowerShell Module.
    Callsign is used to identity:
    - Module Manifest file name
    - Artifact File
    - Git repository name
    - Module name
#>
$CALLSIGN = 'PSCredentialStore'
Write-Host ("Callsign is: {0}" -f $CALLSIGN) -ForegroundColor Black -BackgroundColor Yellow


Function Invoke-InstallDependencies() {
    [CmdletBinding()]
    Param()

    Process {
        Try {
            Write-Host 'Available PS modules are:' -ForegroundColor Green -BackgroundColor Black
            Get-Module -ListAvailable -Name Pester | Format-Table | Out-String
            Get-PackageProvider -ListAvailable
            Install-PackageProvider -Name NuGet -RequiredVersion '2.8.5.208' -Force -Verbose
            Import-PackageProvider -Name NuGet -RequiredVersion '2.8.5.208' -Force
            Write-Host 'Installing build deps...' -ForegroundColor Red -BackgroundColor Black
            Install-Module -Name 'Pester' -Scope CurrentUser -RequiredVersion '4.10.1' -Force -SkipPublisherCheck -AllowClobber -Verbose
            Install-Module -Name 'posh-git' -Scope CurrentUser -RequiredVersion '0.7.3' -Force -SkipPublisherCheck -AllowClobber
            Install-Module -Name 'PSCoverage' -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber -RequiredVersion '1.2.108' -Verbose
            Import-Module -Name 'posh-git'
            Remove-Module -Name 'Pester' -Force -ErrorAction SilentlyContinue
            Import-Module -Name 'Pester' -RequiredVersion '4.10.1' -Verbose -Force
            Import-Module -Name 'PSCoverage' -RequiredVersion '1.2.108' -Verbose -Force
        }
        Catch {
            $MsgParams = @{
                Message  = 'Could not install the required dependencies!'
                Category = 'Error'
                Details  = $_.Exception.Message
            }
            Add-AppveyorMessage @MsgParams
            Throw $MsgParams.Message
        }
        Write-Host 'Loaded PS modules are:' -ForegroundColor Green -BackgroundColor Black
        Get-Module -Name Pester | Format-Table | Out-String
    }
}
Function Invoke-AppVeyorBumpVersion() {
    [CmdletBinding()]
    Param()

    Write-Host "Listing Env Vars for debugging:" -ForegroundColor Black -BackgroundColor Yellow
    # Filter Results to prevent exposing secure vars.
    Get-ChildItem -Path "Env:*" | Where-Object { $_.name -notmatch "(NuGetToken|CoverallsToken|CodeCovToken)" } | Sort-Object -Property Name | Format-Table

    Try {
        $ModManifest = Get-Content -Path (".\src\{0}.psd1" -f $CALLSIGN)
        $BumpedManifest = $ModManifest -replace '0.0.9999', $Env:APPVEYOR_BUILD_VERSION
        Remove-Item -Path (".\src\{0}.psd1" -f $CALLSIGN)
        Out-File -FilePath (".\src\{0}.psd1" -f $CALLSIGN) -InputObject $BumpedManifest -NoClobber -Encoding utf8 -Force
    }
    Catch {
        $MsgParams = @{
            Message  = 'Could not bump current version into module manifest.'
            Category = 'Error'
            Details  = $_.Exception.Message
        }
        Add-AppveyorMessage @MsgParams
        Throw $MsgParams.Message
    }
}

Function Invoke-AppVeyorBuild() {
    [CmdletBinding()]
    [OutputType([PsCustomObject])]
    Param()
    $MsgParams = @{
        Message  = 'Creating build artifacts'
        Category = 'Information'
        Details  = 'Extracting source files and compressing them into zip file.'
    }
    Add-AppveyorMessage @MsgParams
    $CompParams = @{
        Path            = "{0}\src\*" -f $env:APPVEYOR_BUILD_FOLDER
        DestinationPath = "{0}\bin\{1}.zip" -f $env:APPVEYOR_BUILD_FOLDER, $CALLSIGN
        Update          = $True
        Verbose         = $True
    }
    Compress-Archive @CompParams
    $MsgParams = @{
        Message  = 'Pushing artifacts'
        Category = 'Information'
        Details  = 'Pushing artifacts to AppVeyor store.'
    }
    Add-AppveyorMessage @MsgParams
    $ArtifactPath = Join-Path -Path '.' -ChildPath ('bin/{0}.zip' -f $CALLSIGN)
    Push-AppveyorArtifact $ArtifactPath
}

Function Invoke-AppVeyorTests() {
    [CmdletBinding()]
    Param()

    $MsgParams = @{
        Message  = 'Starting Pester tests'
        Category = 'Information'
        Details  = 'Now running all test found in .\tests\ dir.'
    }
    Add-AppveyorMessage @MsgParams

    try {
        Write-Host '===== Preload internal private functions =====' -ForegroundColor Black -BackgroundColor Yellow

        $Privates = Get-ChildItem -Path (Join-Path -Path $Env:APPVEYOR_BUILD_FOLDER -ChildPath '/src/Private/*') -Include "*.ps1" -Recurse
        foreach ($File in $Privates) {
            if (Test-Path -Path $File.FullName) {
                . $File.FullName
                Write-Verbose -Message ('Private function dot-sourced: {0}' -f $File.FullName) -Verbose
            }
            else {
                Write-Warning -Message ('Could not find file: {0} !' -f $File.FullName)
            }
        }
        Write-Host '===== Preload done. =====' -ForegroundColor Black -BackgroundColor Yellow
    }
    catch {
        $_.Exception.Message | Write-Error
        throw 'Could not load required private functions!'
    }

    #$testresults = Invoke-Pester -Path ( Get-ChildItem -Path ".\tests\*.Tests.ps1" -Recurse | Sort-Object -Property Name ) -ExcludeTag 'Disabled' -PassThru
    $srcFiles = Get-ChildItem -Path ".\src\*.ps1" -Recurse | Sort-Object -Property 'Name' | Select-Object -ExpandProperty 'FullName'
    $testFiles = Get-ChildItem -Path ".\tests\*.Tests.ps1" -Recurse | Sort-Object -Property 'Name' | Select-Object -ExpandProperty 'FullName'
    $TestResults = Invoke-Pester -Path $testFiles -CodeCoverage $srcFiles -PassThru -CodeCoverageOutputFile ".\coverage.xml" -CodeCoverageOutputFileEncoding ascii -CodeCoverageOutputFileFormat JaCoCo
    ForEach ($Item in $TestResults.TestResult) {
        Switch ($Item.Result) {
            "Passed" {
                $TestParams = @{
                    Name      = "{0}: {1}" -f $Item.Context, $Item.Name
                    Framework = "NUnit"
                    Filename  = $Item.Describe
                    Outcome   = "Passed"
                    Duration  = $Item.Time.Milliseconds
                }
                Add-AppveyorTest @TestParams
            }
            "Failed" {
                $TestParams = @{
                    Name            = "{0}: {1}" -f $Item.Context, $Item.Name
                    Framework       = "NUnit"
                    Filename        = $Item.Describe
                    Outcome         = "Failed"
                    Duration        = $Item.Time.Milliseconds
                    ErrorMessage    = $Item.FailureMessage
                    ErrorStackTrace = $Item.StackTrace
                }
                Add-AppveyorTest @TestParams
            }
            Default {
                $TestParams = @{
                    Name            = "{0}: {1}" -f $Item.Context, $Item.Name
                    Framework       = "NUnit"
                    Filename        = $Item.Describe
                    Outcome         = "None"
                    Duration        = $Item.Time.Milliseconds
                    ErrorMessage    = $Item.FailureMessage
                    ErrorStackTrace = $Item.StackTrace
                }
                Add-AppveyorTest @TestParams
            }
        }
    }
    If ($TestResults.FailedCount -gt 0) {
        $MsgParams = @{
            Message  = 'Pester Tests failed.'
            Category = 'Error'
            Details  = "$($TestResults.FailedCount) tests failed."
        }
        Add-AppveyorMessage @MsgParams
        Throw $MsgParams.Message
    }

    return $TestResults.CodeCoverage

}

Function Invoke-CoverageReport() {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [String]$RepoToken = $Env:CoverallsToken,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$PesterCoverageReport
    )

    #$CoverageReport | Format-Custom -Depth 5 | Out-String | Write-Verbose
    $CoverageReport = New-CoverageReport -CodeCoverage $PesterCoverageReport -RepoToken $RepoToken
    Write-Host "CoverageReport JSON:" -ForegroundColor Yellow
    #$CoverageReport | ConvertTo-Json -Depth 5 | Out-String | Write-Verbose
    Publish-CoverageReport -CoverageReport $CoverageReport
}


Function Invoke-AppVeyorPSGallery() {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$OnBranch
    )
    Expand-Archive -Path (".\bin\{0}.zip" -f $CALLSIGN) -DestinationPath ("C:\Users\appveyor\Documents\WindowsPowerShell\Modules\{0}\" -f $CALLSIGN) -Verbose
    Import-Module -Name $CALLSIGN -Verbose -Force
    Write-Host "Available Package Provider:" -ForegroundColor Black -BackgroundColor Yellow
    Get-PackageProvider -ListAvailable
    Write-Host "Available Package Sources:" -ForegroundColor Black -BackgroundColor Yellow
    Get-PackageSource
    Try {
        Write-Host "Try to get NuGet Provider:" -ForegroundColor Black -BackgroundColor Yellow
        Get-PackageProvider -Name NuGet -ErrorAction Stop
    }
    Catch {
        Write-Host "Installing NuGet..." -ForegroundColor Black -BackgroundColor Yellow
        Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Force -Verbose
        Import-PackageProvider NuGet -MinimumVersion '2.8.5.201' -Force
    }
    Try {
        If ($env:APPVEYOR_REPO_BRANCH -eq 'master') {
            Write-Host "try to publish module" -ForegroundColor Black -BackgroundColor Yellow
            Write-Host ("Callsign is: {0}" -f $CALLSIGN) -ForegroundColor Black -BackgroundColor Yellow
            Publish-Module -Name $CALLSIGN -NuGetApiKey $env:NuGetToken -Verbose -Force -AllowPrerelease
        }
        Else {
            Write-Host "Skip publishing to PS Gallery because we are on $($env:APPVEYOR_REPO_BRANCH) branch." -ForegroundColor Black -BackgroundColor Yellow
            # had to remove the publish-Module statement because it would publish although the -WhatIf is given.
            # Publish-Module -Name $CALLSIGN -NuGetApiKey $env:NuGetToken -Verbose -WhatIf
        }
    }
    Catch {
        $MsgParams = @{
            Message  = 'Could not deploy module to PSGallery.'
            Category = 'Error'
            Details  = $_.Exception.Message
        }
        $_.Exception.Message | Write-Error
        Add-AppveyorMessage @MsgParams
        Throw $MsgParams.Message
    }
}
