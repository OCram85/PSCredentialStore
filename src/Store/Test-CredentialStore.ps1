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

    .NOTES
        - File Name   : Test-CredentialStore.ps1
        - Author      : Marco Blessing - marco.blessing@googlemail.com
        - Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding(DefaultParameterSetName = 'Private')]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'Shared')]
        [string]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'Shared')]
        [switch]$Shared
    )

    begin {
        # Set latest Credential Store version
        #Set-Variable -Name 'CSVersion' -Value '2.0.0' -Option Constant
    }

    process {
        # Set the CredentialStore for private, shared or custom mode.
        Write-Debug ('ParameterSetName: {0}' -f $PSCmdlet.ParameterSetName)

        # Construct a empty splatting.
        $params = @{}

        # Check if the user did not supply a custom path.
        if (-not $PSBoundParameters.ContainsKey('Path')) {
            # If the user supplied the -Shared parameter, add -Shared to the splatting.
            if ($PSCmdlet.ParameterSetName -eq 'Shared') {
                $params.Add('Shared', $true)
            }

            # Get the default CredentialStorePath.
            $Path = Get-DefaultCredentialStorePath @params
        }

        Write-Verbose -Message ('Path is: {0}' -f $Path)

        if (Test-Path $Path) {
            Write-Verbose 'CredentialStore in given path found.'
            return $true
        }
        else {
            Write-Verbose 'The given CredentialStore does not exist!'
            return $false
        }
    }

    end { }

}
