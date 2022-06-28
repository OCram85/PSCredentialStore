BeforeAll {
    $ManifestFile = (Get-Item -Path "./src/*.psd1").FullName
    Import-Module $ManifestFile -Force
}

Describe "New-CSCertAttribute" {
    Context "Basis Tests" {
        It "TShould not throw" {
            {
                $AttribParams = @{
                    Country                = 'DE'
                    State                  = 'BW'
                    City                   = 'KA'
                    Organization           = 'IT'
                    OrganizationalUnitName = ''
                    CommonName             = 'MyCert'
                }
                New-CSCertAttribute @AttribParams
            } | Should -Not -Throw
        }
    }
}
