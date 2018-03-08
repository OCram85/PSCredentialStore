$RepoRoot = (Get-GitDirectory).replace('\.git', '')

Describe "Pre-Flight module tests" {
    $ManifestFilePath = "{0}\src\PSCredentialstore.psd1" -f $RepoRoot
    Context "Manifest file related" {
        It "Test the parsed file itsef" {
            { Test-ModuleManifest -Path $ManifestFilePath } | Should -Not -Throw
        }
    }
    Context "Module consistency tests" {
        IT "Importing should work" {
            { Import-Module -Name $ManifestFilePath -Global } | Should -Not -Throw
        }
    }
}
