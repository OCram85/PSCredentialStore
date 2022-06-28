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

Describe "Get-ModuleBase" {
    Context "Basic syntax check" {
        It "Test1: Should not throw" {
            { Get-ModuleBase } | Should -Not -Throw
        }
    }
}
