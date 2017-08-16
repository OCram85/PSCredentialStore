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


# Backup existing credential stores
$VerbosePreference = "Continue"
Write-Verbose "Backup private Credential Store..."
$CSPath = ("{0}\CredentialStore.json" -f $env:APPDATA)
$BackupFile = "{0}.back" -f $CSPath
If (Test-Path -Path $CSPath) {
    Move-Item -Path $CSPath -Destination $BackupFile
}
Write-Verbose "Backup shared CredentialStore..."
$CSShared = ("{0}\PSCredentialStore\CredentialStore.json" -f $env:ProgramData)
$BackupSharedFile = "{0}.back" -f $CSShared
If (Test-Path -Path $CSShared) {
    Move-Item -Path $CSShared -Destination $BackupSharedFile
}
Write-Verbose "Remove old CredentialStore in Temp dir"
$CSTemp = "{0}\CredentialStore.json" -f $Env:TEMP
If (Test-Path -Path $CSTemp) {
    Remove-Item -Path $CSTemp
}
$VerbosePreference = "SilentlyContinue"

Describe "New-CredentialStore" {
    Context "Private CS tests" {
        $pCS = Join-Path -Path $env:APPDATA -ChildPath "CredentialStore.json"
        It "Test1: Create new private CredentialStore" {
            New-CredentialStore
            $result = Test-Path -Path $pCS
            $CS = Get-Content -Path $pCS -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
            ($result -eq $True) -and ($CS.Type -eq "Private") | Should Be $True
        }
        It "Test2: Try to override private Store" {
            {New-CredentialStore} | Should Throw
        }
        It "Test3: Reset existing Credential Store" {
            $now = Get-Date
            $CS = Get-Content -Path $pCS -Raw | ConvertFrom-Json
            $CSCreation = [DateTime]$CS.Creation
            New-CredentialStore -Force
            $now -gt $csCreation | Should Be $True
        }
    }
    Context "Shared CS tests" {
        $pCS = Join-Path -Path $env:ProgramData -ChildPath "PSCredentialStore\CredentialStore.json"
        It "Test1: Create a new Shared Credential Store" {
            New-CredentialStore -Shared
            Test-Path -Path ("{0}\PSCredentialStore\CredentialStore.json" -f $env:ProgramData) | Should Be $True
        }
        It "Test2: Try to override existing shared CS" {
            {New-CredentialStore -Shared} | Should Throw
        }
        It "Test3: Reset shared CredentialStore" {
            $now = Get-Date
            $CS = Get-Content -Path $pCS -Raw | ConvertFrom-Json
            $CSCreation = [DateTime]$CS.Creation
            New-CredentialStore -Force -Shared
            $now -gt $csCreation | Should Be $True
        }
    }
    Context "Custom Shared CS tests" {
        $pCS = Join-Path -Path $env:TEMP -ChildPath "CredentialStore.json"
        It "Test1: Create new custom shared" {
            {New-CredentialStore -Path $pCS -Shared} | Should Not Throw
        }
        It "Test2: Try to override exiting one" {
            {New-CredentialStore -Path $pCS -Shared} | Should Throw
        }
        It "Test3: Reset existing custom CredentialStore" {
            {New-CredentialStore -Path $pCS -Shared -Force} | Should Not Throw
        }
    }
}

# Cleanup test stores and restore existing ones.
$VerbosePreference = "Continue"
Write-Verbose "Restoring private CredentialStore"
If (Test-Path -Path $BackupFile) {
    If (Test-Path -Path $CSPath) {
        Remove-Item -Path $CSPath
        Move-Item -Path $BackupFile -Destination $CSPath
    }
}

Write-Verbose "Restoring shared CredentialStore"
If (Test-Path -Path $BackupSharedFile) {
    If (Test-Path -Path $CSShared) {
        Remove-Item -Path $CSShared
        Move-Item -Path $BackupSharedFile -Destination $CSShared
    }
}
$VerbosePreference = "SilentlyContinue"
