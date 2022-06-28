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

Describe "New-CredentialStoreItem" {
    Context "Private Credential Store tests" {
        It "Add entry to existing private store." {
            # Creat a fresh CredentialStore first
            New-CredentialStore -Force

            [String]$tmp = (65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ }
            $tmp = $tmp.Replace(' ', '')
            $tmpUser = "MyUser"
            $tmpPwd = "fooobarysdfsfs" | ConvertTo-SecureString -AsPlainText -Force
            $creds = [PSCredential]::new($tmpUser, $tmpPwd)
            New-CredentialStoreItem -RemoteHost $tmp -Credential $creds
            # Had to remove the `{ <exp> } | Shoud Not Throw` because the return would be empty.
            $content = Get-CredentialStoreItem -RemoteHost $tmp
            $content.UserName | Should -Be "MyUser"
            #Cleanup Temp entry
            $CS = Get-CredentialStore
            $CS.PSObject.Properties.Remove($tmp)
            ConvertTo-Json -InputObject $CS | Out-File -FilePath (Get-DefaultCredentialStorePath)
        }
    }
    Context "Test with new shared Credential Store" {
        It "Create new RemoteHost entry" {
            # prepare test environment
            $tmpCS = Join-Path -Path (Get-TempDir) -ChildPath '/CredentialStore.json'
            New-CredentialStore -Shared -Path $tmpCS -Force

            $UserName = "myuser"
            $Password = ConvertTo-SecureString -String "mypasswd" -AsPlainText -Force
            $mycreds = [PSCredential]::new($UserName, $Password)
            $RemoteHost = "foobar"
            { New-CredentialStoreItem -Shared -Path $tmpCS -RemoteHost $RemoteHost -Credential $mycreds } | Should -Not -Throw
            $tmpCS = Get-Content -Path $tmpCS -Raw | ConvertFrom-Json
            $res = Get-Member -InputObject $tmpCS -Name $RemoteHost -Membertype Properties
            $res.Name | Should -Be $RemoteHost
        }
        It "Adds Item with identifier to shared store" {
            $tmpCS = Join-Path -Path (Get-TempDir) -ChildPath '/CredentialStore.json'
            New-CredentialStore -Shared -Path $tmpCS -Force

            $UserName = "myuser"
            $Password = ConvertTo-SecureString -String "mypasswd" -AsPlainText -Force
            $mycreds = [PSCredential]::new($UserName, $Password)
            $RemoteHost = "foobar2"
            New-CredentialStoreItem -Shared -Path $tmpCS -RemoteHost $RemoteHost -Credential $mycreds -Identifier 'Foo'
            $writtenItem = Get-CredentialStoreItem -Shared -Path $tmpCS -RemoteHost $RemoteHost -Identifier 'Foo'
            ($writtenItem.UserName -eq $UserName) -and ($writtenItem.Password.Length -gt 0) | Should -Be $true
        }
    }
    Context "Test optional parameter lookup" {
        It "Test missing Credential" {
            function global:Get-Credential ([string]$Message) {
                $UserName = 'testuser'
                $Password = ConvertTo-SecureString -String "mypasswd" -AsPlainText -Force
                return [PSCredential]::new($UserName, $Password)
            }
            $tmpCS = Join-Path -Path (Get-TempDir) -ChildPath '/CredentialStore.json'
            New-CredentialStoreItem -Path $tmpCs -Shared -RemoteHost 'foobar3'
            $writtenItem = Get-CredentialStoreItem -Path $tmpCS -Shared -RemoteHost 'foobar3'
            $writtenItem.UserName | Should -Be "testuser"

            Remove-Item -Path 'Function:\Get-Credential'
        }

    }
    Context "General Exception handling" {
        Mock Test-CredentialStore { return $false } -ModuleName 'PSCredentialStore'
        It "Missing CredentialStore should throw" {
            { New-CredentialStoreItem -Shared -Path '/tmp/missingStore.json' -RemoteHost 'notrelevant' } | Should -Throw "Could not add anything"
        }
    }
    Context "Testing pipeline paramter" {
        It "Add the item with credential value from pipe" {
            $UserName = 'pipeUser'
            $Password = ConvertTo-SecureString -String "pipePasswd" -AsPlainText -Force
            { [PSCredential]::new($UserName, $Password) | New-CredentialStoreItem -RemoteHost 'PipeHost' } | Should -Not -Throw
        }

        It "Testing written item" {
            (Get-CredentialStoreItem -RemoteHost 'PipeHost').UserName | Should -Be 'pipeUser'
        }
    }
    Context "Testing items with certficiate store" {
        It "Create item in new store with cert store link" {
            New-CredentialStore -UseCertStore -Force

            $Path = Get-DefaultCredentialStorePath
            $StoreHome = Split-Path -Path $Path -Parent
            $CertFile = Join-Path -Path $StoreHome -ChildPath 'PSCredentialStore.pfx'
            $Cert = Get-PfxCertificate -FilePath $CertFile

            $myStore = [System.Security.Cryptography.X509Certificates.X509Store]::new('My')
            $myStore.Open("ReadWrite")
            $myStore.Add($Cert)
            $MyStore.Close()

            $UserName = 'testuser'
            $Password = ConvertTo-SecureString -String "mypasswd" -AsPlainText -Force

            [PSCredential]::new($UserName, $Password) | New-CredentialStoreItem -RemoteHost 'foobarcerts'

            $writtenItem = Get-CredentialStoreItem -RemoteHost 'foobarcerts'
            $writtenItem.UserName | Should -Be "testuser"
            $writtenItem.GetNetworkCredential().Password | Should -Be 'mypasswd'
        }
    }

}
