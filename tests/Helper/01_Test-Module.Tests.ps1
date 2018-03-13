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
#. (Get-ChildItem -Path $RepoRoot -Filter "<FunctionName>.ps1" -Recurse).FullName

#endregion HEADER

Describe "Test-ModuleName" {
    Context "Basic input tests" {
        It "Testing standard module should not throw" {
            { Test-Module -Name 'PowerShellGet' -Type Module } | Should -Not -Throw
        }
        It "Existing module should return true" {
            Test-Module -Name 'PowerShellGet' -Type Module | Should -Be $true
        }
    }
    Context "Custom Type tests" {
        It "Using custom type should throw" {
            { Test-Module -Name "foobarr" -Type Custom} | Should -Throw
        }
    }
    Context "Working with PSSnapins" {
        It "Loading first PSSnaping should not throw " {
            $Snap = Get-PSSnapin -Registered | Select-Object -First 1
            { Test-Module -Name $Snap.Name -Type PSSnapin } | Should -Not -Throw
        }
        It "Loading first PSSnaping should return true" {
            $Snap = Get-PSSnapin -Registered | Select-Object -First 1
            Test-Module -Name $Snap.Name -Type PSSnapin | Should -Be $true
        }
        It "Not existing PSSnaping should return false" {
            Test-Module -Name 'foobar2000' -Type PSSnapin | Should -Be $false
        }
        It "StopifFails switch should thrown an error" {
            {Test-Module -Name 'foobar2000' -Type PSSnapin }| Should -Throw
        }
    }
    Context "Working with modules" {
        It "Loading first module should not throw " {
            $Mod = Get-Module -ListAvailable | Select-Object -First 1
            { Test-Module -Name $Mod.Name -Type Module } | Should -Not -Throw
        }
        It "Loading first module should return true" {
            $Snap = Get-Module -ListAvailable | Select-Object -First 1
            Test-Module -Name $Snap.Name -Type Module | Should -Be $true
        }
        It "Not existing module should return false" {
            Test-Module -Name 'foobar2000' -Type Module | Should -Be $false
        }
        It "StopifFails switch should thrown an error" {
            {Test-Module -Name 'foobar2000' -Type Module }| Should -Throw
        }
    }
}
