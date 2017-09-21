function Remove-CredentialStoreItem {
    <#
    .SYNOPSIS
        Remove the given credentials from the credential store.

    .DESCRIPTION
        Use this CMDLet to completely remove an credential store item.

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
        Remove-CredentialStoreItem -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local"
        Remove-CredentialStoreItem -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local" -Identifier svc

    .NOTES
        File Name   : Remove-CredentialStoreItem.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

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

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [switch]$Shared
    )

    # First set a constand path for private CredentialStore mode.
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

    if ($Identifier -ne "") {
        $CredentialName = $RemoteHost = "{0}/{1}" -f $Identifier, $RemoteHost
    }
    else {
        $CredentialName = $RemoteHost
    }

    if (Get-Member -InputObject $CSContent -Name $CredentialName -Membertype Properties) {
        # We need to use the .NET Method because there is no easier way in PowerShell.
        $CSContent.PSObject.Properties.Remove($CredentialName)
        ConvertTo-Json -InputObject $CSContent | Out-File -FilePath $Path
    }
    else {
        $MessageParams = @{
            Message = "The given CredentailStoreItem does not exist."
        }
        Write-Warning @MessageParams
    }
}
