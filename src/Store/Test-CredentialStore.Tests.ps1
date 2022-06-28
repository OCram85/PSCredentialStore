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

    $RepoRoot = (Get-Item -Path (Get-GitDirectory) -Force).Parent | Select-Object -ExpandProperty 'FullName'
}

Describe "Test-CredentialStore" {
    Context "Basic logic tests" {
        $TestCredentialStore = Join-Path -Path $RepoRoot -ChildPath '/resources/cs/CredentialStore.json'
        It "Test1: Should Not Throw" {
            { Test-CredentialStore -Shared -Path $TestCredentialStore } | Should -Not -Throw
        }
        It "Test2: Read valid CredentialStore" {
            $res = Test-CredentialStore -Shared -Path $TestCredentialStore
            $res | Should -Be $true
        }
        It "Test3: Read a broken CredentialStore" {
            $BrokenCS = Join-Path -Path $RepoRoot -ChildPath '{0}/resources/cs/Broken_CS.json'
            $oWarningPreference = $WarningPreference
            $WarningPreference = 'SilentlyContinue'
            $res = Test-CredentialStore -Shared -Path $BrokenCS
            $res | Should -Be $false
            $WarningPreference = $oWarningPreference
        }
        It "Test4: Not existing path should return false" {
            if ($isWindows -or ($PSVersionTable.PSVersion.Major -eq 5)) {
                Test-CredentialStore -Shared -Path 'C:\foobar\CredentialStore.json' | Should -Be $false
            }
            elseif ($isWindows -or $IsMacOS) {
                Test-CredentialStore -Shared -Path '/var/opt/foo.json' | Should -Be $false
            }
        }
        It "Test5: testing private CredentialStore path" {
            if (Test-Path -Path (Get-DefaultCredentialStorePath)) {
                Remove-Item -Path (Get-DefaultCredentialStorePath)
            }
            Test-CredentialStore | Should -Be $false
        }
    }
}
