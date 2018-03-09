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
#. (Get-ChildItem -Path $RepoRoot -Filter "Test-CredentialStore.ps1" -Recurse).FullName
#. (Get-ChildItem -Path $RepoRoot -Filter "New-CredentialStore.ps1" -Recurse).FullName
#. (Get-ChildItem -Path $RepoRoot -Filter "Get-CredentialStore.ps1" -Recurse).FullName
#. (Get-ChildItem -Path $RepoRoot -Filter "Get-CredentialStoreItem.ps1" -Recurse).FullName
. (Get-ChildItem -Path $RepoRoot -Filter "Test-ChallengeFile.ps1" -Recurse).FullName
. (Get-ChildItem -Path $RepoRoot -Filter "Get-ChallengeFile.ps1" -Recurse).FullName
. (Get-ChildItem -Path $RepoRoot -Filter "Set-ChallengeFile.ps1" -Recurse).FullName
. (Get-ChildItem -Path $RepoRoot -Filter "Get-RandomKey.ps1" -Recurse).FullName

#endregion HEADER

Describe "New-CredentialStoreItem" {
    Context "Private Credential Store tests" {
        It "Test1: Add entry to existing private store." {
            If (-not (Test-CredentialStore)) {
                New-CredentialStore
            }
            [String]$tmp = (65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_}
            $tmp = $tmp.Replace(' ', '')
            $tmpUser = "MyUser"
            $tmpPwd = "fooobarysdfsfs" | ConvertTo-SecureString -AsPlainText -Force
            $creds = New-Object -TypeName PsCredential -ArgumentList $tmpUser, $tmpPwd
            New-CredentialStoreItem -RemoteHost $tmp -Credential $creds
            # Had to remove the `{ <exp> } | Shoud Not Throw` because the return would be empty.
            $content = Get-CredentialStoreItem -RemoteHost $tmp
            $content.UserName | Should Be "MyUser"
            #Cleanup Temp entry
            $CS = Get-CredentialStore
            $CS.PSObject.Properties.Remove($tmp)
            ConvertTo-Json -InputObject $CS | Out-File -FilePath ("{0}\CredentialStore.json" -f $env:AppData)
        }
    }
    Context "Test with new shared Credential Store" {
        It "Test2: Create new RemoteHost entry" {
            # prepare test environment
            $tmpCS = 'C:\CredentialStore.json'
            New-CredentialStore -Shared -Path $tmpCS

            $UserName = "myuser"
            $Password = ConvertTo-SecureString -String "mypasswd" -AsPlainText -Force
            $mycreds = New-Object -TypeName PSCredential -ArgumentList $UserName, $Password
            $RemoteHost = "foobar"
            { New-CredentialStoreItem -Path $tmpCS -RemoteHost $RemoteHost -Credential $mycreds -Shared } | Should Not Throw
            $tmpCS = Get-Content -Path $tmpCS -Raw | ConvertFrom-Json
            $res = Get-Member -InputObject $tmpCS -Name $RemoteHost -Membertype Properties
            $res.Name | Should Be $RemoteHost
        }
    }
}
