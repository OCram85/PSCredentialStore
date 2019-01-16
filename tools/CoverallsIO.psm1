function Get-GitInfo {
    [CmdletBinding()]
    param(
        [string]$BranchName
    )

    if ($Env:AppVeyor) {
        return [PSCustomObject]@{
            head   = [PSCustomObject]@{
                id             = $Env:APPVEYOR_REPO_COMMIT
                author_name    = $Env:APPVEYOR_REPO_COMMIT_AUTHOR
                author_email   = $Env:APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL
                comitter_name  = $Env:APPVEYOR_REPO_COMMIT_AUTHOR
                comitter_email = $Env:APPVEYOR_REPO_COMMIT_AUTHOR_EMAIL
                message        = $Env:APPVEYOR_REPO_COMMIT_MESSAGE
            }
            branch = $Env:APPVEYOR_REPO_BRANCH
        }
    }
    else {
        if (-not $BranchName) {
            $BranchName = (git rev-parse --abbrev-ref HEAD)
        }
        return [PSCustomObject]@{
            head   = [PSCustomObject]@{
                id              = (git log --format="%H" HEAD -1)
                author_name     = (git log --format="%an" HEAD -1)
                author_email    = (git log --format="%ae" HEAD -1)
                committer_name  = (git log --format="%cn" HEAD -1)
                committer_email = (git log --format="%ce" HEAD -1)
                message         = (git log --format="%s" HEAD -1)
            }
            branch = $BranchName
        }
    }
}

function New-CoverageReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$CodeCoverage,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoToken,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleRoot = $(Get-Location)
    )
    begin {
        $CoverReport = [PSCustomObject]@{
            repo_token   = $RepoToken
            commit_sha   = (git log --format="%H" HEAD -1)
            git          = Get-GitInfo
            service_name = 'appveyor'
            source_files = @()
        }
    }

    process {
        # Find all files with hit commands -> These file have pester tests
        $UsedFiles = $CodeCoverage.AnalyzedFiles | Where-Object {
            $CodeCoverage.HitCommands.File -contains $_
        }

        foreach ($SourceFile in $UsedFiles) {
            $Lines = (Get-Content -Path $SourceFile | Measure-Object).Count
            Write-Verbose ("SourceFile: {0} | LinesCount: {1}" -f $SourceFile, $Lines)
            $CoverageArray = @()
            $Hits = 0
            $Missed = 0

            for ($LinePointer = 1; $LinePointer -le $Lines; $LinePointer++) {

                # Get only hit commands from current src file
                $curHits = $CodeCoverage.HitCommands | Where-Object {
                    $_.File -eq $SourceFile
                }
                [int]$Hits = (
                    $curHits | Where-Object {
                        $_.Line -eq $LinePointer
                    } | Measure-Object
                ).Count

                # again filter only missed commands from the curent file
                $curMissed = $CodeCoverage.MissedCommands | Where-Object {
                    $_.File -eq $SourceFile
                }
                [int]$Missed = (
                    $curMissed | Where-Object {
                        $_.Line -eq $LinePointer
                    } | Measure-Object
                ).Count

                Write-Verbose ("SourceFile:{0} | Line: {1} | Hits: {2} | Missed: {3}" -f $SourceFile, $LinePointer, $Hits, $Missed)
                if ((-not $Hits -gt 0) -and (-not $Missed -gt 0)) {
                    $CoverageArray += 'null'
                }
                else {
                    if ($Hits -gt 0) {
                        $CoverageArray += $Hits
                    }
                    elseif ($Missed -gt 0) {
                        $CoverageArray += 0
                    }
                }
            }
            # Get rid of the quotation
            $CoverageArray = $CoverageArray -Replace '"', ''
            $CoverageSourceFile = [PSCustomObject]@{
                name          = $SourceFile.Replace($ModuleRoot, '').Replace('\', '/')
                source_digest = (Get-FileHash -Path $SourceFile -Algorithm MD5).Hash
                coverage      = $CoverageArray
            }
            If ($CoverageSourceFile.Name.StartsWith('/')) {
                $CoverageSourceFile.Name = $CoverageSourceFile.Name.Remove(0, 1)
            }
            $CoverReport.source_files += $CoverageSourceFile
        }

        # Find all untested files to create a null coverage file
        $UnUsedFiles = $CodeCoverage.AnalyzedFiles | Where-Object {
            $CodeCoverage.HitCommands.File -notcontains $_
        }

        foreach ($UnUsedFile in $UnUsedFiles) {
            $Lines = (Get-Content -Path $UnUsedFile | Measure-Object).Count
            $CoverageArray = @()
            for ($LinePointer = 1; $LinePointer -le $Lines; $LinePointer++) {
                $CoverageArray += '0'
            }
            $CoverageSourceFile = [PSCustomObject]@{
                name          = $UnUsedFile.Replace($ModuleRoot, '').Replace('\', '/')
                source_digest = (Get-FileHash -Path $UnUsedFile -Algorithm MD5).Hash
                coverage      = $CoverageArray
            }
            if ($CoverageSourceFile.Name.StartsWith('/')) {
                $CoverageSourceFile.Name = $CoverageSourceFile.Name.Remove(0, 1)
            }
            $CoverReport.source_files += $CoverageSourceFile
        }
    }

    end {
        Write-Output $CoverReport
    }
}

function Publish-CoverageReport () {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]$CoverageReport
    )
    begin {
        Add-Type -AssemblyName System.Net.Http
    }

    process {
        $CoverageJSON = ConvertTo-Json $CoverageReport -Depth 5
        # Try to fix null elements in coverage array.
        $CoverageJSON = $CoverageJSON.Replace('"null"', 'null')
        $stringContent = New-Object System.Net.Http.StringContent ($CoverageJSON)
        $httpClient = New-Object System.Net.Http.Httpclient
        $formdata = New-Object System.Net.Http.MultipartFormDataContent
        $formData.Add($stringContent, "json_file", "coverage.json")
        $result = $httpClient.PostAsync('https://coveralls.io/api/v1/jobs', $formData).Result
        $content = $result.Content.ReadAsStringAsync()
    }

    end {
        Write-Output $Content
    }
}
