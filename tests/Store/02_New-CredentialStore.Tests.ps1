# Backup existing credential stores
$VerbosePreference = "Continue"
Write-Verbose "Backup private Credential Store..."
$CSPath = Get-DefaultCredentialStorePath
$BackupFile = "{0}.back" -f $CSPath
If (Test-Path -Path $CSPath) {
    Move-Item -Path $CSPath -Destination $BackupFile
}
Write-Verbose "Backup shared CredentialStore..."
$CSShared = Get-DefaultCredentialStorePath -Shared
$BackupSharedFile = "{0}.back" -f $CSShared
If (Test-Path -Path $CSShared) {
    Move-Item -Path $CSShared -Destination $BackupSharedFile
}
Write-Verbose "Remove old CredentialStore in Temp dir"
$CSTemp = Join-Path -Path (Get-TempDir) -ChildPath '/CredentialStore.json'
If (Test-Path -Path $CSTemp) {
    Remove-Item -Path $CSTemp
}
$VerbosePreference = "SilentlyContinue"

Describe "New-CredentialStore" {
    Context "Private CS tests" {
        $pCS = Get-DefaultCredentialStorePath
        It "Test1: Create new private CredentialStore" {
            { New-CredentialStore -Confirm:$false } | Should -Not -Throw
            $result = Test-Path -Path $pCS
            $CS = Get-Content -Path $pCS -Raw | ConvertFrom-Json
            ($result -eq $true) -and ($CS.Type -eq "Private") | Should -Be $true
        }
        It "Test2: Try to override private Store" {
            { New-CredentialStore -Confirm:$false } | Should -Throw
        }
        It "Test3: Reset existing Credential Store" {
            $now = Get-Date
            $CS = Get-Content -Path $pCS -Raw | ConvertFrom-Json
            $CSCreation = [DateTime]$CS.Created
            New-CredentialStore -Confirm:$false -Force
            $now -gt $csCreation | Should -Be $true
        }
    }
    Context "Shared CS tests" {
        $sCS = Get-DefaultCredentialStorePath -Shared
        It "Test1: Create a new Shared Credential Store" {
            { New-CredentialStore -Confirm:$false -Shared } | Should -Not -Throw
            Test-Path -Path $sCS | Should -Be $true
        }
        It "Test2: Try to override existing shared CS" {
            { New-CredentialStore -Shared -Confirm:$false } | Should -Throw
        }
        It "Test3: Reset shared CredentialStore" {
            $now = Get-Date
            $CS = Get-Content -Path $sCS -Raw | ConvertFrom-Json
            $CSCreation = [DateTime]$CS.Created
            New-CredentialStore -Force -Shared -Confirm:$false
            $now -gt $csCreation | Should -Be $true
        }
    }
    Context "Custom Shared CS tests" {
        $cCS = Join-Path -Path (Get-TempDir) -ChildPath "CredentialStore.json"
        It "Test1: Create new custom shared" {
            { New-CredentialStore -Path $cCS -Shared -Confirm:$false } | Should -Not -Throw
        }
        It "Test2: Try to override exiting one" {
            { New-CredentialStore -Path $cCS -Shared -Confirm:$false } | Should -Throw
        }
        It "Test3: Reset existing custom CredentialStore" {
            { New-CredentialStore -Path $cCS -Shared -Force -Confirm:$false } | Should -Not -Throw
        }
    }
    Context "Test exception handling" {
        Mock Out-File { throw "foobar exception" }
        It "JSON Conversion should fail and throw" {
            { New-CredentialStore -Path (Join-Path -Path (Get-TempDir) -ChildPath '/dummy.json') -Shared -Confirm:$false } | Should -Throw
        }
    }
    Context "Tests for Windows certificate store" {
        It "Create new private store and skip certificate linking" {
            { New-CredentialStore -UseCertStore -Force } | Should -Not -Throw
            $CS = Get-CredentialStore
            $CS.PfxCertificate | Should -Be $null
            $CS.Thumbprint | Should -Not -Be $null
            $res = Test-CSCertificate -Type Private
            #Write-Verbose -Message ('res: {0}' -f $res) -Verbose
            $res | Should -Be $true

        }
        It "Create new shared store and skipt certificate linking" {
            { New-CredentialStore -Shared -UseCertStore -Force } | Should -Not -Throw
            $CS = Get-CredentialStore -Shared
            $CS.PfxCertificate | Should -Be $null
            $CS.Thumbprint | Should -Not -Be $null
            $res = Test-CSCertificate -Type Shared
            #Write-Verbose -Message ('res: {0}' -f $res) -Verbose
            $res | Should -Be $true
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
