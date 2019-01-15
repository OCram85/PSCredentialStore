Describe "Test-ModuleName" {
    Context "Basic input tests" {
        It "Testing standard module should not throw" {
            { Test-Module -Name 'PowerShellGet' } | Should -Not -Throw
        }
        It "Existing module should return true" {
            Test-Module -Name 'PowerShellGet' | Should -Be $true
        }
    }
    Context "Working with modules" {
        It "Loading first module should not throw " {
            $Mod = Get-Module -ListAvailable | Select-Object -First 1
            { Test-Module -Name $Mod.Name } | Should -Not -Throw
        }
        It "Loading first module should return true" {
            $Snap = Get-Module -ListAvailable | Select-Object -First 1
            Test-Module -Name $Snap.Name | Should -Be $true
        }
        It "Not existing module should return false" {
            Test-Module -Name 'foobar2000' | Should -Be $false
        }
        It "StopifFails switch should thrown an error" {
            {Test-Module -Name 'foobar2000' -StopIfFails }| Should -Throw
        }
    }
}
