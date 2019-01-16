Describe "Get-TempDir" {
    Context "Basic tests" {
        It "Should not throw" {
            {Get-TempDir} | Should -Not -Throw
        }
        It "Should return the correct os tmp path" {
            $Path = Get-TempDir

            if ($ENV:TRAVIS) {
                if ($IsLinux) {
                    $RefPath = (Resolve-Path -Path '/tmp/').Path
                    $Path | Should -Be $RefPath
                }
                if ($IsMacOS) {
                    $RefPath = (Resolve-Path -Path '/tmp/').Path
                    $Path | Should -Be $RefPath
                }
            }
            if ($Env:APPVEYOR) {
                if (($isWindows) -or ($PSVersionTable.PSVersion.Major -lt 6) -or ($PSVersionTable.PSEdition -eq 'Desktop')) {
                    $RefPath = (Resolve-Path -Path $env:TEMP).Path
                    $Path | Should -Be $RefPath
                }
            }
        }
    }
}
