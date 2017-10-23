function Get-CredentialStore {
    <#
    .SYNOPSIS
        Reads the complete content of the credential store and returns it as a new object.

    .DESCRIPTION
        The content is in a raw format. It means there is no transformation to the different credential types.
        You can not use the object properties to connect with remote host. Therefore please use
        Get-CredentialStoreItem.

    .PARAMETER Path
        Define a custom path to a shared CredentialStore.

    .PARAMETER Shared
        Switch to shared mode with this param. This enforces the command to work with a shared CredentialStore which
        can be decrypted across systems.

    .INPUTS
        [None]

    .OUTPUTS
        [PSObject] Returns the credential store content as PSObject.

    .EXAMPLE
        $CSContent = Get-CredentialStore -Path "C:\TMP\mystore.json"

    .NOTES
        ```
        File Name   : Get-CredentialStore.ps1
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

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [switch]$Shared
    )

    if ($PSCmdlet.ParameterSetName -eq 'Private') {
        $Path = "{0}\CredentialStore.json" -f $env:APPDATA
    }

    if (Test-CredentialStore -Path $Path) {
        try {
            $FileContent = Get-Content -Path $Path -Raw
            ConvertFrom-Json $FileContent
        }
        catch [System.Exception] {
            $MessageParams = @{
                Message = "Unknown CredentialStore format. Invalid JSON file."
                ErrorAction = "Stop"
            }
            Write-Error @MessageParams
        }
    }
    else {
        $MessageParams = @{
            Message = "Could not find the CredentialStore."
            ErrorAction = "Stop"
        }
        Write-Error @MessageParams
    }
}
