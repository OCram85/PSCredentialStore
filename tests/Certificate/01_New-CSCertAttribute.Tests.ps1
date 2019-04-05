Describe "New-CSCertAttribute" {
    Context "Basis Tests" {
        It "Test1: Should not throw " {
            { New-CSCertAttribute -Country 'DE' -State 'BW' -City 'KA' -Organization 'IT' -OrganizationalUnitName'' -CommonName 'Mycert' } | Should -Not -Throw
        }
    }
}
