Describe "New-CSCertificate" {
    Context "Basic Tests" {
        It "Test1: Should not throw" {

            $attribs = New-CSCertAttribute -Country 'DE' -State 'BW' -City 'KA' -Organization 'IT' -OrganizationalUnitName'' -CommonName 'Mycert'

            $CertAttribs = @{
                CRTAttribute = $attribs
                KeyName      = Join-Path -Path (Get-TempDir) -ChildPath '/foo.key'
                CertName     = Join-Path -Path (Get-TempDir) -ChildPath '/cert.pfx'
            }
            { New-CSCertificate @CertAttribs } | Should -Not -Throw
        }
    }
}
