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

Describe "Get-CredentialStore" {
    Context "Basic logic tests" {
        It "Test1: Read CS without params" {
            $TestCredentialStore = './resources/cs/CredentialStore.json'
            $TestPfxCert = './resources/cs/PSCredentialStore.pfx'
            if (! (Test-Path -Path (Get-DefaultCredentialStorePath)) ) {
                { New-CredentialStore -Force } | Should -Not -Throw
            }
            { Get-CredentialStore } | Should -Not -Throw
        }
        It "Test2: Read Credential Store with testing data" {
            $TestCredentialStore = './resources/cs/CredentialStore.json'
            $TestPfxCert = './resources/cs/PSCredentialStore.pfx'
            {
                Use-CSCertificate -Shared -CredentialStore $TestCredentialStore -Path $TestPfxCert
            } | Should -Not -Throw
            { Get-CredentialStore -Shared -Path $TestCredentialStore } | Should -Not -Throw
        }
        It "Test3: Not existing path should return false" {
            {
                Get-CredentialStore -Shared -Path './CredentialStore.json'
            } | Should -Throw "Could not find the CredentialStore."
        }
    }
    Context "Testing invalid json data" {
        It "Should throw with invalid CredentialStore" {
            $BrokenCS = './resources/cs/Broken_CS.json'
            Write-Verbose -Message ('BrokenCS Path: {0}' -f $BrokenCS) -Verbose
            {
                Get-CredentialStore -Path -Shared $BrokenCS
            } | Should -Throw
        }
    }
}
