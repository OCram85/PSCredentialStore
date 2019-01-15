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

    .NOTES
        ```
        File Name   : Test-CredentialStore.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :
        ```
    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding(DefaultParameterSetName = "Private")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [string]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = "Shared")]
        [switch]$Shared
    )

    begin {
        # Set latest Credential Store version
        #Set-Variable -Name "CSVersion" -Value "2.0.0" -Option Constant
    }

    process {
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
        Write-Verbose -Message ("Path is: {0}" -f $Path)

        if (Test-Path $Path) {
            Write-Verbose "CredentialStore in given path found."
            return $true
        }
        else {
            Write-Verbose "The given CredentialStore does not exist!"
            return $false
        }
    }

    end {}

}
