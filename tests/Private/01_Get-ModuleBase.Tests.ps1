Describe "Get-ModuleBase" {
    Context "Basic syntax check" {
        It "Test1: Should not throw" {
            { Get-ModuleBase } | Should -Not -Throw
        }
    }
}
