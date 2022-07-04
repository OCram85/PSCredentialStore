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

Describe "Get-RandomKey" {
    Context "Basic input tests" {
        It "Test1: Should not throw " {
            { Get-RandomAESKey } | Should -Not -Throw
        }
    }
    Context "Basic syntax check" {
        It "Test2: Should return a key with a length of 32 bytes" {
            $Key = Get-RandomAESKey
            $Key.length | Should -Be 32
        }
    }
}
