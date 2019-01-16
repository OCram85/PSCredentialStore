$RepoRoot = (Get-Item -Path (Get-GitDirectory) -Force).Parent | Select-Object -ExpandProperty 'FullName'

Describe "Get-CredentialStore" {
    Context "Basic logic tests" {
        $TestCredentialStore = Join-Path -Path $RepoRoot -ChildPath 'resources/cs/CredentialStore.json'
        $TestPfxCert = Join-Path -Path $RepoRoot -ChildPath 'resources/cs/PSCredentialStore.pfx'
        'TestCredentialStore: {0}' -f $TestCredentialStore
        It "Test1: Read CS without params" {
            if (! (Test-Path -Path (Get-DefaultCredentialStorePath)) ) {
                { New-CredentialStore -Force } | Should -Not -Throw

            }
            { Get-CredentialStore } | Should -Not -Throw
        }
        It "Test2: Read Credential Store with testing data" {
            { Use-PfxCertificate -Shared -CredentialStore $TestCredentialStore -Path $TestPfxCert } | Should -Not -Throw
            { Get-CredentialStore -Shared -Path $TestCredentialStore } | Should -Not -Throw
        }
        It "Test3: Not existing path should return false" {
            { Get-CredentialStore -Shared -Path './CredentialStore.json'  }| Should -Throw "Could not find the CredentialStore."
        }
    }
    Context "Testing invalid json data" {
        #Mock Test-CredentialStore {return $true}
        #Mock Get-Content {return '"foo":"bar",'}
        $BrokenCS = Join-Path -Path $RepoRoot -ChildPath 'resources/cs/Broken_CS.json'
        Write-Verbose -Message ('BrokenCS Path: {0}' -f $BrokenCS) -Verbose
        It "Should throw with invalid CredentialStore" {
            { Get-CredentialStore -Path -Shared $BrokenCS } | Should -Throw
        }
    }
}
