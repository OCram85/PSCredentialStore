#region HEADER
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
# $RepoRoot = (Get-Item -Path $here).Parent.Parent.FullName
$RepoRoot = (Get-GitDirectory).replace('\.git', '')
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sut = $sut -replace "\d{2}`_", ''
$suthome = (Get-ChildItem -Path $RepoRoot -Exclude ".\tests\" -Filter $sut -Recurse).FullName
# Skip try loading the source file if it doesn't exists.
If ($suthome.Length -gt 0) {
    . $suthome
}
Else {
    Write-Warning ("Could not find source file {0}" -f $sut)
}

# load additional functions defined in the repository. Replace the expression <FunctionName>.
# . (Get-ChildItem -Path $RepoRoot -Filter "<Function-Name>.ps1" -Recurse).FullName

#endregion HEADER

Describe "Get-CredentialStore" {
    Context "Basic logic tests" {
        $TestCredentialStore = Resolve-Path -Path ("{0}\resources\cs\CredentialStore.json" -f $RepoRoot)
        It "Test1: Read CS without params" {
            If (Test-Path -Path ("{0}\CredentialStore.json" -f $env:APPDATA)) {
                {Get-CredentialStore} | Should Not Throw
            }
            Else {
                Write-Warning "Default private Credential Store not found. Skipping..."
            }
        }
        It "Test2: Read Credential Store with testing data" {

            {Get-CredentialStore -Path $TestCredentialStore} | Should Not Throw
        }
    }
}
