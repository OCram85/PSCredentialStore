function Test-CredentialStore {
    <#
    .SYNOPSIS
        Returns the credential store state.

    .DESCRIPTION
        Use this script to test your credential store. For now it only checks if
        the file exists.

    .PARAMETER Path
        Define a custom path to a shared CredentialStore.

    .PARAMETER Shared
        Switch to shared mode with this param. This enforces the command to work with a shared CredentialStore which
        can be decrypted across systems.

    .EXAMPLE
        Test-CredentialStore -eq $true

    #>
    [CmdletBinding(DefaultParameterSetName = 'Private')]
    [OutputBinding([boolean])]
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
        Write-Verbose -Message ("Path is: {0}" -f $Path)

        if (Test-Path $Path) {
            Write-Verbose 'CredentialStore in given path found.'
            Write-Output $true
        }
        else {
            Write-Verbose 'The given CredentialStore does not exist!'
            Write-Output $false
        }
    }

    end {}

}
