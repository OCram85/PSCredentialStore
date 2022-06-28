function New-CredentialStoreItem {
    <#
    .SYNOPSIS
        Adds a credential store item containing host, user and password to the given store.

    .DESCRIPTION
        The credentials are stored without any relations to it's further use. If you need to change an existing
        item please use Set-CredentialStoreItem. You need to decide afterwards, whether to use the credential for
        a VIConnection, NetApp FAS or UCS Fabric Interconnect.

    .PARAMETER Path
        Define the store in which you would like to add a new item.

    .PARAMETER RemoteHost
        The identifier or rather name for the given credentials.

    .PARAMETER Identifier
        Provide a custom identifier to the given remote host key. This enables you to store multiple credentials
        for a single remote host entry. For example ad/sys1, ftp/sys1, mssql/sys1

    .PARAMETER Credential
        You can provide credentials optionally as pre existing pscredential object.

    .PARAMETER Shared
        Define the CredentialStore where you want to add the new item. Default is always personal but can be
        changed to shared, or even shared with custom path.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        New-CredentialStoreItem -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local"
    #>

    [CmdletBinding(DefaultParameterSetName = 'Private')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Shared')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Private')]
        [ValidateNotNullOrEmpty()]
        [string]$RemoteHost,

        [Parameter(Mandatory = $false, ParameterSetName = 'Shared')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Private')]
        [ValidateNotNullOrEmpty()]
        [string]$Identifier,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,

        [Parameter(Mandatory = $true, ParameterSetName = 'Shared')]
        [switch]$Shared,

        [Parameter(Mandatory = $false, ParameterSetName = 'Shared')]
        [ValidateNotNullOrEmpty()]
        [string]$Path


    )

    begin {
        # Set the CredentialStore for private, shared or custom mode.
        Write-Debug ("ParameterSetName: {0}" -f $PSCmdlet.ParameterSetName)
        if ($PSCmdlet.ParameterSetName -eq 'Private') {
            $Path = Get-DefaultCredentialStorePath
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Shared') {
            if (!($PSBoundParameters.ContainsKey('Path'))) {
                $Path = Get-DefaultCredentialStorePath -Shared
            }
        }
    }

    process {
        # Lets do a quick test on the given CredentialStore.
        if (-not(Test-CredentialStore -Shared -Path $Path)) {
            $MessageParams = @{
                Exception   = [System.IO.FileNotFoundException]::new(
                    'Could not add anything into the given CredentialStore.'
                )
                ErrorAction = "Stop"
            }
            Write-Error @MessageParams
        }

        $CSContent = Get-CredentialStore -Shared -Path $Path

        $CurrentDate = Get-Date -Format 'u'

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
            if ($null -eq $CSContent.PfxCertificate) {
                $Cert = Get-CSCertificate -Type $CSContent.Type -Thumbprint $CSContent.Thumbprint
            }
            else {
                $Cert = Get-PfxCertificate -FilePath $CSContent.PfxCertificate -ErrorAction Stop
            }

            if (Get-Member -InputObject $CSContent -Name $CredentialName -Membertype Properties) {
                $MessageParams = @{
                    Message = 'The given host already exists. Nothing to do here.'
                }
                Write-Warning @MessageParams
            }
            else {
                $RSAKey = Get-RandomAESKey

                $CredentialHash = [ordered]@{
                    User         = $Credential.UserName
                    Password     = ConvertFrom-SecureString -SecureString $Credential.Password -Key $RSAKey
                    Created      = $CurrentDate
                    LastChange   = $null
                    EncryptedKey = [Convert]::ToBase64String($Cert.PublicKey.Key.Encrypt($RSAKey, [System.Security.Cryptography.RSAEncryptionPadding]::Pkcs1))
                }
                Add-Member -InputObject $CSContent -Name $CredentialName -MemberType NoteProperty -Value $CredentialHash
                try {
                    ConvertTo-Json -InputObject $CSContent | Out-File -FilePath $Path
                }
                catch {
                    $MessageParams = @{
                        Message     = 'Could not add item into credential store!'
                        ErrorAction = 'Stop'
                    }
                    Write-Error @MessageParams
                }
            }
        }
        else {
            $MessageParams = @{
                Message     = 'Please Provide at least a valid user!'
                ErrorAction = 'Stop'
            }
            Write-Error @MessageParams
        }
    }

    end {}

}
