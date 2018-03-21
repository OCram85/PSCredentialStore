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
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [string]$Path = "{0}\PSCredentialStore\CredentialStore.json" -f $env:ProgramData,

        [Parameter(Mandatory = $true, ParameterSetName = "Private")]
        [Parameter(Mandatory = $true, ParameterSetName = "Shared")]
        [string]$RemoteHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Private")]
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [string]$Identifier,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [switch]$Shared
    )

    # First set a constant path for private CredentialStore mode.
    if ($PSCmdlet.ParameterSetName -eq "Private") {
        $Path = "{0}\CredentialStore.json" -f $env:APPDATA
    }

    # Lets do a quick test on the given CredentialStore.
    if (-not(Test-CredentialStore -Path $Path)) {
        $MessageParams = @{
            Message = "Could not add anything into the given CredentailStore."
            ErrorAction = "Stop"
        }
        Write-Error @MessageParams
    }

    # Read the file content based on the given ParameterSetName
    $CSContent = Get-CredentialStore -Path $Path

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
        if ($CSContent.Type -eq "Shared") {
            $Key = Get-ChallengeFile
            $encypted = ConvertFrom-SecureString -SecureString $Credential.Password -Key $Key
        }
        else {
            $encypted = ConvertFrom-SecureString -SecureString $Credential.Password
        }
        if (Get-Member -InputObject $CSContent -Name $CredentialName -Membertype Properties) {
            $CSContent.$CredentialName.User = $Credential.UserName
            $CSContent.$CredentialName.Password = $encypted
            $CSContent.$CredentialName.Creation = $CurrentDate
            ConvertTo-Json -InputObject $CSContent | Out-File -FilePath $Path
        }
        else {
            $MessageParams = @{
                Message = "The given CredentailStoreItem does not exist."
            }
            Write-Warning @MessageParams
        }
    }
    Else {
        $MessageParams = @{
            Message = "Please Provide at least a valid user!"
            ErrorAction = "Stop"
        }
        Write-Error @MessageParams
    }
}
