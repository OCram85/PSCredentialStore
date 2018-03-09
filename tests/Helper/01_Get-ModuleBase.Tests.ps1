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

Describe "Get-ModuleBase" {
    Context "Basic syntax check" {
        It "Test1: Should not throw" {
            { Get-ModuleBase } | Should -Not -Throw
        }
    }
}
