function Update-CredentialStore {
    <#
    .SYNOPSIS
        A brief description of the function or script.

    .DESCRIPTION
        Describe the function of the script using a single sentence or more.

    .PARAMETER One
        Description of the Parameter (what it does)

    .INPUTS
        Describe the script input parameters (if any), otherwise it may also list the word "[None]".

    .OUTPUTS
        Describe the script output parameters (if any), otherwise it may also list the word "[None]".

    .EXAMPLE
        .\Remove-Some-Script.ps1 -One content

    .NOTES
        File Name   : Update-CredentialStore.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Version]$From = '1.2.0',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Version]$To = '2.0.0',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$PfxCertificate

    )
    begin {
    }
    process {
        if (Test-Path -Path $Path) {
            $CSOld = Get-CredentialStore -Shared -Path $Path -ErrorAction Stop
            if ($CSOld.Version -ne $From) {
                $ErrorParams = @{
                    Message     = 'Can not migrate CredentialStore from version {0} to {1}' -f $From, $To
                    ErrorAction = 'Stop'
                    Exception   = [System.Exception]::new()
                }
                Write-Error @ErrorParams
            }

            $CSNew = [PSCustomObject]@{
                PSTypeName     = 'PSCredentialStore.Store'
                Version        = $To
                Created        = $CurrentDate
                PfxCertificate = $null
                Thumbprint     = $null
                Type           = $null
            }

            if ($PWD -eq (Get-DefaultCredentialStorePath)) {
                $CSNew.Type = 'Private'
            }
            elseif ($PWD -eq (Get-DefaultCredentialStorePath -Shared)) {
                $CSNew.Type = 'Shared'
            }
            else {
                $ErrorParams = @{
                    Message     = 'Can not determine a valid CredentialStore Type!'
                    ErrorAction = 'Stop'
                    Exception   = [System.Exception]::new()
                }
                Write-Error @ErrorParams
            }
            $Cert = Get-PfxCertificate -FilePath $PfxCertificate -ErrorAction Stop

            $CSNew.PfxCertificate = Join-Path -Path $PfxCertificate
            $CSNew.Thumbprint = $Cert.Thumbprint


            $CredentialItems = $CSOld | Get-Member -MemberType NoteProperty | Where-Object {
                $_.Definition -like "*.PSCustomObject*"
            } | Select-Object -ExpandProperty Name

            # iterate through all existing items
            foreach ($Item in $CredentialItems) {

                $CurrentDate = Get-Date -UFormat "%Y-%m-%d %H:%M:%S"
                $RSAKey = Get-RandomAESKey

                $CredentialObj = [PSCustomObject]@{
                    User         = $Item.UserName
                    Password     = $null
                    Created      = $CurrentDate
                    LastChange   = $null
                    EncryptedKey = [Convert]::ToBase64String(
                        $Cert.PublicKey.Key.Encrypt(
                            $RSAKey,
                            [System.Security.Cryptography.RSAEncryptionPadding]::Pkcs1
                        )
                    )
                }
                if ($CSOld.Type -eq 'Private') {
                    $CredentialObject.Password = ConvertTo-SecureString -SecureString $Item.Password | ConvertFrom-SecureString -Key $RSAKey
                }
                elseif ($CSNew.Type -eq 'Shared') {
                    $ChallengeKey = [io.file]::ReadAllBytes((Join-Path -Path $PWD -ChildPath '/Challenge.bin'))
                    $CredentialObject.Password = ConvertTo-SecureString -SecureString $Item.Password -Key $ChallengeKey | ConvertFrom-SecureString -Key $RSAKey
                }
                Add-Member -InputObject $CSNew -Name (
                    ($Item | Get-Variable).Name
                ) -MemberType NoteProperty -Value $CredentialObj
            }
            $CSNew | ConvertTo-Json -Depth 5 | Out-File -LiteralPath (
                Join-Path -Path $PWD -ChildPath './CredentialStore.json'
            ) -Encoding utf8 -Confirm:$true
        }
        else {
            $ErrorParams = @{
                Message     = 'Could not find the given CredentialStore path!'
                ErrorAction = 'Stop'
                Exception   = [System.IO.FileNotFoundException]::new()
            }
            Write-Error @ErrorParams
        }
    }
    end {
    }
}
