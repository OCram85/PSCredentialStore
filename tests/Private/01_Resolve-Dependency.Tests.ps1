Describe "Resolve-Dependency" {
    Context "Basic syntax check" {
        Mock Get-ModuleBase {return (Join-Path -Path $PWD -ChildPath '/resources')}
        Mock Test-Module {return $true}
        It "Test1: Should not throw" {
            { Resolve-Dependency -Name 'foobar2000' } | Should -Not -Throw
        }
        It "Test2: Output type should be bool" {
            Resolve-Dependency -Name 'foobar2000' | Should -BeOfType bool
        }
    }
    Context "Enforce Error" {
        # Return incorrect module base to enforce there is no config file.
        Mock Get-ModuleBase {
            if ($IsWindows) {return "C:\"}
            elseif ($isLinux) {return "/"}
        }
        It "Missing dependency file should not cause an error" {
            { Resolve-Dependency -Name 'awesome'} | Should -Not -Throw
        }

        It "Missing dependency file should return true" {
            Resolve-Dependency -Name 'awesome' | Should -Be $true
        }
    }
    Context "Testing input variations" {
        Mock Get-ModuleBase {return (Join-Path -Path $PWD -ChildPath '/resources')}
        It "Should return true if all given dependencies exist" {
            Resolve-Dependency -Name 'Existing' | Should -Be $true
        }
        It "Mixed results should return false" {
            Resolve-Dependency -Name 'PSGetMixed' | Should -Be $false
        }
    }
}
