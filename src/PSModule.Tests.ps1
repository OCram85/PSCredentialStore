Describe 'Test module meta' {
    Context 'Default tests' -Tag 'Default' {
        It 'Test manifest file' {
            $ManifestFile = (Get-Item -Path "./src/*.psd1").FullName
            Test-ModuleManifest -Path $ManifestFile | Should -Be $true
        }
        It 'Import Module' {
            $ManifestFile = (Get-Item -Path "./src/*.psd1").FullName
            { Import-Module $ManifestFile } | Should -Not -Throw
        }
    }
}
