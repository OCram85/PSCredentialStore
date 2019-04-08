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
        Remove-CredentialStoreItem -RemoteHost "esx01.myside.local"

    .EXAMPLE
        Remove-CredentialStoreItem -Shared -RemoteHost "esx01.myside.local"

    .EXAMPLE
        Remove-CredentialStoreItem -Shared -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local"

    .EXAMPLE
        Remove-CredentialStoreItem -RemoteHost "esx01.myside.local" -Identifier svc

    .NOTES
        - File Name   : Remove-CredentialStoreItem.ps1
        - Author      : Marco Blessing - marco.blessing@googlemail.com
        - Requires    :

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
                Message     = "Could not add anything into the given CredentialStore."
                ErrorAction = "Stop"
            }
            Write-Error @MessageParams
        }

        # Read the file content based on the given ParameterSetName
        $CSContent = Get-CredentialStore -Shared -Path $Path

        if ($Identifier -ne "") {
            $CredentialName = $RemoteHost = "{0}/{1}" -f $Identifier, $RemoteHost
        }
        else {
            $CredentialName = $RemoteHost
        }

        if (Get-Member -InputObject $CSContent -Name $CredentialName -Membertype NoteProperty) {
            # We need to use the .NET Method because there is no easier way in PowerShell.
            $CSContent.PSObject.Properties.Remove($CredentialName)
            ConvertTo-Json -InputObject $CSContent -Depth 5 | Out-File -FilePath $Path -Encoding utf8
        }
        else {
            $MessageParams = @{
                Message = "The given CredentialStoreItem does not exist."
            }
            Write-Warning @MessageParams
        }
    }

    end {

    }

}
