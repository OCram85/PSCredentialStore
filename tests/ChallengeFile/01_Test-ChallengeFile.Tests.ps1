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
#. (Get-ChildItem -Path $RepoRoot -Filter "Test-ChallengeFile.ps1" -Recurse).FullName

#endregion HEADER

Describe "Test-ChallengeFile" {
    Context "Basic input tests" {
        Mock Test-Path {return $true}
        It "No parameter with existing challenge file" {
            {Test-ChallengeFile} | Should -Not -Throw
        }
        It "No parameter and existing file should return true" {
            Test-ChallengeFile | Should -Be $true
        }
    }
    Context "Execute with parameter" {
        $TestChFile = "{0}\resources\cs\Challenge.bin" -f $RepoRoot
        It "Provide valid path" {
            Test-ChallengeFile -Path $TestChFile | Should -Be $true
        }
        It "Provide fake path" {
            Test-ChallengeFile -Path "C:\notexisting.bin" | Should -Be $false
        }
    }
}
