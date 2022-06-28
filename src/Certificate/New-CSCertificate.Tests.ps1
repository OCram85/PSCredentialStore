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
                CRTAttribute = New-CSCertAttribute @attribs
                KeyName      = Join-Path -Path (Get-TempDir) -ChildPath '/foo.key'
                CertName     = Join-Path -Path (Get-TempDir) -ChildPath '/cert.pfx'
            }
            { New-CSCertificate @CertAttribs } | Should -Not -Throw
        }
    }
}
