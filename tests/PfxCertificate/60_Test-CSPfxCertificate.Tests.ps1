Describe "Test-CSPfxCertificate" {
    Context "Basic Tests" {
        It "Should not Throw" {
            { Test-CSPfxCertificate -Thumbprint '12345' -StoreName My -StoreLocation CurrentUser } | Should -Not -Throw
        }
        It "Should return false" {
            Test-CSPfxCertificate -Thumbprint '12345' -StoreName My -StoreLocation CurrentUser | Should -Be $false
        }
    }
}
