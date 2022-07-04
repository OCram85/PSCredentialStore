BeforeAll {
    $ManifestFile = (Get-Item -Path "./src/*.psd1").FullName
    Import-Module $ManifestFile -Force
}

Describe "New-CSCertAttribute" {
    Context "Basis Tests" -Tag 'Unit' {
        It "Should not throw" {
            $AttribParams = @{
                Country                = 'DE'
                State                  = 'BW'
                City                   = 'KA'
                Organization           = 'IT'
                OrganizationalUnitName = 'foo'
                CommonName             = 'MyCert'
            }
            { New-CSCertAttribute @AttribParams } | Should -Not -Throw
        }
    }
}
