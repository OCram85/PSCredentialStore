BeforeAll {
    $ManifestFile = (Get-Item -Path "./src/*.psd1").FullName
    Import-Module $ManifestFile -Force
}

Describe "New-CSCertificate" {
    Context "Basic Tests" -Tag 'Unit' {
        It "Should not throw" {
            $attribs = @{
                Country                = 'DE'
                State                  = 'BW'
                City                   = 'KA'
                Organization           = 'IT'
                OrganizationalUnitName = 'foo'
                CommonName             = 'MyCert'
            }
            $CertAttribs = @{
                CRTAttribute = $attribs
                KeyName      = Join-Path -Path (Get-TempDir) -ChildPath '/foo.key'
                CertName     = Join-Path -Path (Get-TempDir) -ChildPath '/cert.pfx'
            }
            { New-CSCertificate @CertAttribs } | Should -Not -Throw
        }
    }
}
