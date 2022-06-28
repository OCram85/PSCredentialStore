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
    #>

    [CmdletBinding(DefaultParameterSetName = 'Private')]
    [OutputType('PSCredentialStore.Store')]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Shared')]

        [string]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'Shared')]
        [switch]$Shared
    )

    begin {}

    process {
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

        if (Test-CredentialStore -Path $Path -Shared) {
            try {
                $FileContent = Get-Content -Path $Path -Raw
                $CS = ConvertFrom-Json $FileContent
                $CS.PSObject.TypeNames.Insert(0, 'PSCredentialStore.Store')
                Write-Output $CS
            }
            catch [System.Exception] {
                $MessageParams = @{
                    Message     = 'Unknown CredentialStore format. Invalid JSON file.'
                    ErrorAction = 'Stop'
                }
                Write-Error @MessageParams
            }
        }
        else {
            $MessageParams = @{
                Message     = 'Could not find the CredentialStore.'
                ErrorAction = 'Stop'
            }
            Write-Error @MessageParams
        }
    }

    end {}

}
