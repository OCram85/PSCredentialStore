function Set-CredentialStoreItem {
    <#
    .SYNOPSIS
        Changes the credentials for the given remote host in the store.

    .DESCRIPTION

    .PARAMETER Path
        Define the store in which your given host entry already exists.

    .PARAMETER RemoteHost
        Specify the host you for which you would like to change the credentials.

    .PARAMETER Identifier
        Defaults to "". Specify a string, which separates two CredentialStoreItems for the
        same hostname.

    .PARAMETER Shared
        Switch to shared mode with this param. This enforces the command to work with a shared CredentialStore which
        can be decrypted across systems.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        Set-CredentialStoreItem -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local"
        Set-CredentialStoreItem -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local" -Identifier svc

    .NOTES
        ```
        File Name   : Set-CredentialStoreItem.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :
        ```

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>

    [CmdletBinding(DefaultParameterSetName = "Private")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Private")]
        [Parameter(Mandatory = $true, ParameterSetName = "Shared")]
        [string]$RemoteHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Private")]
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [string]$Identifier,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,

        [Parameter(Mandatory = $true, ParameterSetName = "Shared")]
        [switch]$Shared,

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    begin {
        # Set the CredentialStore for private, shared or custom mode.
        Write-Debug ("ParameterSetName: {0}" -f $PSCmdlet.ParameterSetName)
        if ($PSCmdlet.ParameterSetName -eq "Private") {
            $Path = Get-DefaultCredentialStorePath
        }
        elseif ($PSCmdlet.ParameterSetName -eq "Shared") {
            if (!($PSBoundParameters.ContainsKey('Path'))) {
                $Path = Get-DefaultCredentialStorePath -Shared
            }
        }
    }

    process {
        # Lets do a quick test on the given CredentialStore.
        if (-not(Test-CredentialStore -Shared -Path $Path)) {
            $MessageParams = @{
                Message     = "Could not add anything into the given CredentailStore."
                ErrorAction = "Stop"
            }
            Write-Error @MessageParams
        }

        # Read the file content based on the given ParameterSetName
        $CSContent = Get-CredentialStore -Shared -Path $Path

        $CurrentDate = Get-Date -UFormat "%Y-%m-%d %H:%M:%S"

        if ($Identifier -ne "") {
            $CredentialName = $RemoteHost = "{0}/{1}" -f $Identifier, $RemoteHost
        }
        else {
            $CredentialName = $RemoteHost
        }

        if (-not($Credential)) {
            $Credential = Get-Credential -Message $CredentialName
        }

        if ($Credential.UserName) {
            $Cert = Get-CSCertificate -Type $CSContent.Type -Thumbprint $CSContent.Thumbprint

            if (Get-Member -InputObject $CSContent -Name $CredentialName -Membertype Properties) {
                $RSAKey = Get-RandomAESKey
                $CSContent.$CredentialName.User = $Credential.UserName
                $CSContent.$CredentialName.Password = ConvertFrom-SecureString -SecureString $Credential.Password -Key $RSAKey
                $CSContent.$CredentialName.LastChange = $CurrentDate
                $CSContent.$CredentialName.EncryptedKey = [Convert]::ToBase64String(
                    $Cert.PublicKey.Key.Encrypt(
                        $RSAKey,
                        [System.Security.Cryptography.RSAEncryptionPadding]::Pkcs1
                    )
                )
                ConvertTo-Json -InputObject $CSContent -Depth 5 | Out-File -FilePath $Path -Encoding utf8
            }
        }
        Else {
            $MessageParams = @{
                Message     = "Please Provide at least a valid user!"
                ErrorAction = "Stop"
            }
            Write-Error @MessageParams
        }
    }

    end {

    }
}
