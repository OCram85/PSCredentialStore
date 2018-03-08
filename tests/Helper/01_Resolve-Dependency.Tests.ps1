#region HEADER
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# $RepoRoot = (Get-Item -Path $here).Parent.Parent.FullName
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
. (Get-ChildItem -Path $RepoRoot -Filter "Get-ModuleBase.ps1" -Recurse).FullName
. (Get-ChildItem -Path $RepoRoot -Filter "Test-Module.ps1" -Recurse).FullName
#endregion HEADER

Describe "Resolve-Dependency" {
    Context "Basic syntax check" {
        Mock Get-ModuleBase {return "{0}\resources" -f $PWD}
        Mock Test-Module {return $true}
        It "Test1: Should not throw" {
            { Resolve-Dependency -Name 'foobar2000' } | Should -Not -Throw
        }
        It "Test2: Output type should be bool" {
            Resolve-Dependency -Name 'foobar2000' | Should -BeOfType bool
        }
    }
}
