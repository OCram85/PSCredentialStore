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

Describe "Test-CredentialStore" {
    Context "Basic logic tests" {
        $TestCredentialStore = Resolve-Path -Path ("{0}\resources\cs\CredentialStore.json" -f $RepoRoot)
        It "Test1: Should Not Throw" {
            { Test-CredentialStore -Path $TestCredentialStore } | Should Not Throw
        }
        It "Test2: Read valid CredentialStore" {
            $res = Test-CredentialStore -Path $TestCredentialStore
            $res | Should Be $True
        }
        It "Test3: Read a broken CredentialStore" {
            $BrokenCS = Resolve-Path -Path ("{0}\resources\cs\Broken_CS.json" -f $RepoRoot)
            $oWarningPreference = $WarningPreference
            $WarningPreference = 'SilentlyContinue'
            $res = Test-CredentialStore -Path $BrokenCS
            $res | Should Be $False
            $WarningPreference = $oWarningPreference
        }
        It "Test4: Not existing path should return false" {
            Test-CredentialStore -Path 'C:\foobar\CredentialStore.json' | Should -Be $false
        }
        It "Test5: testing private CredentialStore path" {
            if (Test-Path -Path ("{0}\CredentialStore.json" -f $env:APPDATA) ) {
                Remove-Item -Path ("{0}\CredentialStore.json" -f $env:APPDATA)
            }
            Test-CredentialStore | Should -Be $false
        }
    }
}
