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
# . (Get-ChildItem -Path $RepoRoot -Filter "<FunctionName>.ps1" -Recurse).FullName

#endregion HEADER

Describe "Get-RandomKey" {
    Context "Basic input tests" {
        It "Test1: Should throw if wrong size is given" {
            {Get-RandomKey -size 43} | Should -Throw
        }
    }
    Context "Basic syntax check" {
        It "Test1: Should return a key with a length of 16" {
            $Key = Get-RandomKey -size 16
            $Key.length | Should -Be 16
        }
        It "Test2: Should return a key with a length of 24" {
            $Key = Get-RandomKey -size 24
            $Key.length | Should -Be 24
        }
        It "Test3: Should return a key with a length of 32" {
            $Key = Get-RandomKey -size 32
            $Key.length | Should -Be 32
        }
    }
}
