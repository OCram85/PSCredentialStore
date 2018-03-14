#region HEADER
$RepoRoot = (Get-GitDirectory).replace('\.git', '')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sut = $sut -replace "\d{2}`_", ''
$suthome = (Get-ChildItem -Path $RepoRoot -Exclude ".\tests\" -Filter $sut -Recurse).FullName
# Skip try loading the source file if it doesn't exists.
If ($suthome.Length -gt 0) {
    . $suthome
}
Else {
    Write-Warning ("Could not find source file {0}" -f $sut)
}

# load additional functions defined in the repository. Replace the expression <FunctionName>.
. (Get-ChildItem -Path $RepoRoot -Filter "Get-RandomKey.ps1" -Recurse).FullName

#endregion HEADER

Describe "Set-ChallengeFile" {
    Context "Tests with custom path" {
        It "Working dir and path not exist" {
            {Set-ChallengeFile -Path 'C:\PSCredentialStore\Challenge.bin'} | Should -Not -Throw
        }
        It "No parameter and non file should return true" {
            if (Test-Path -Path ("{0}\PSCredentialStore\Challenge.bin" -f $env:ProgramData)) {
                Remove-Item -Path ("{0}\PSCredentialStore\Challenge.bin" -f $env:ProgramData)
            }
            Set-ChallengeFile
            Test-Path -Path ("{0}\PSCredentialStore\Challenge.bin" -f $env:ProgramData) | Should -Be $true
        }
        It "Existing Credential file should return error" {
            { Set-ChallengeFile } | Should -Throw
            Remove-Item -Path ("{0}\PSCredentialStore\Challenge.bin" -f $env:ProgramData)
        }
        It "Use -Force switch should create a new challenge file" {
            # prepare for test and clean up old data
            if (Test-Path -Path ("{0}\PSCredentialStore\Challenge.bin" -f $env:ProgramData)) {
                Remove-Item -Path ("{0}\PSCredentialStore\Challenge.bin" -f $env:ProgramData)
            }
            Set-ChallengeFile
            { Set-ChallengeFile -Force } | Should -Not -Throw
        }
        It "Test directory creation for shared store" {
            if (Test-Path -Path ("{0}\PSCredentialStore" -f $env:ProgramData)) {
                Remove-Item -Path ("{0}\PSCredentialStore" -f $env:ProgramData) -Force -Recurse
            }
            Set-ChallengeFile
            Test-Path -Path ("{0}\PSCredentialStore" -f $env:ProgramData) | Should -Be $true
        }
    }
    Context "General Exception handling" {
        Mock New-Item {throw "foobar exception"}
        It "Test exception handling if the root directory could not be created" {
            if (Test-Path -Path ("{0}\PSCredentialStore" -f $env:ProgramData)) {
                Remove-Item -Path ("{0}\PSCredentialStore" -f $env:ProgramData) -Force -Recurse
            }
            { Set-ChallengeFile } | Should -Throw "Could not create the parent data dir"
        }
    }
}
