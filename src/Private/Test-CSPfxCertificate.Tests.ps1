BeforeAll {
    $ManifestFile = (Get-Item -Path "./src/*.psd1").FullName
    Import-Module $ManifestFile -Force

    $PrivateFunctions = (Get-ChildItem -Path "./src/Private/*.ps1" | Where-Object {
            $_.BaseName -notmatch '.Tests'
        }
    ).FullName
    foreach ( $func in $PrivateFunctions) {
        . $func
    }
}

Describe "Test-CSPfxCertificate" {
    Context "Basic Tests" {
        It "Should not Throw" {
            {
                Test-CSPfxCertificate -Thumbprint '12345' -StoreName My -StoreLocation CurrentUser
            } | Should -Not -Throw
        }
        It "Should return false" {
            Test-CSPfxCertificate -Thumbprint '12345' -StoreName My -StoreLocation CurrentUser | Should -Be $false
        }
    }
}
