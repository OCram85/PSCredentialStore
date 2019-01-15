$RepoRoot = (Get-Item -Path (Get-GitDirectory) -Force).Parent | Select-Object -ExpandProperty 'FullName'
Write-Verbose -Message ('RepoRoot: {0}' -f $RepoRoot) -Verbose

$ManifestFilePath = Join-Path -Path $RepoRoot -ChildPath '/src/PSCredentialStore.psd1'
Write-Verbose -Message ("ManifestFilePath: {0}" -f $ManifestFilePath) -Verbose
Describe "Pre-Flight module tests" {
    Context "Manifest file related" {
        It "Test the parsed file itself" {
            { Test-ModuleManifest -Path $ManifestFilePath -Verbose } | Should -Not -Throw
        }
    }
    Context "Module consistency tests" {
        It "Importing should work" {
            { Import-Module -Name $ManifestFilePath -Global -Force -Verbose } | Should -Not -Throw
        }
    }
}
