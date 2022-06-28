Describe 'Test module meta' {
    It 'Test manifest file' {
        $ManifestFile = (Get-Item -Path "./src/*.psd1").FullName
        Test-ModuleManifest -Path $ManifestFile | Should -Be $true
    }
    It 'Import Module' {
        $ManifestFile = (Get-Item -Path "./src/*.psd1").FullName
        { Import-Module $ManifestFile } | Should -Not -Throw
    }
    # Dummy test to force pester error
    #It 'Force Pester Error' {
    #    $true | Should -BeFalse
    #}
}
