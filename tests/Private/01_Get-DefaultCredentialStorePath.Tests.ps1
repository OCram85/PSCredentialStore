Describe "Get-DefaultCredentialStorePath" {
    Context "Basic syntax test" {
        It "Test1: Should not throw" {
            { Get-DefaultCredentialStorePath } | Should -Not -Throw
        }
    }

    Context "Private Type" {
        It "Should return correct paths" {
            $Path = Get-DefaultCredentialStorePath
            #Write-Verbose -Message ('Delivered path is: {0}' -f $Path) -Verbose
            if ($Env:APPVEYOR) {
                $PathRef = Join-Path -Path $Env:APPDATA -ChildPath 'CredentialStore.json'
                $Path | Should -Be $PathRef
            }
            elseif ($ENV:TRAVIS) {
                if ($IsLinux) {
                    $PathRef = Join-Path -Path $Env:HOME -ChildPath 'CredentialStore.json'
                    $Path | Should -Be $PathRef
                }
                elseif ($IsMacOS) {
                    $PathRef = Join-Path -Path $Env:HOME -ChildPath 'CredentialStore.json'
                    $Path | Should -Be $PathRef
                }
            }
        }
    }

    Context "Shared Type" {
        It "Should return correct paths" {
            $Path = Get-DefaultCredentialStorePath -Shared
            #Write-Verbose -Message ('Delivered path is: {0}' -f $Path) -Verbose
            if ($Env:APPVEYOR) {
                $PathRef = Join-Path -Path $env:ProgramData -ChildPath 'PSCredentialStore/CredentialStore.json'
                $Path | Should -Be $PathRef
            }
            elseif ($ENV:TRAVIS) {
                if ($IsLinux) {
                    $PathRef = Join-Path -Path '/var/opt' -ChildPath 'PSCredentialStore/CredentialStore.json'
                    $Path | Should -Be $PathRef
                }
                elseif ($IsMacOS) {
                    $PathRef = Join-Path -Path '/var/opt' -ChildPath 'PSCredentialStore/CredentialStore.json'
                    $Path | Should -Be $PathRef
                }
            }
        }
    }
}
