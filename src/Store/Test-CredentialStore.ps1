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
        [string]$Path = "{0}\PSCredentialStore\CredentialStore.json" -f $env:ProgramData,

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [switch]$Shared
    )


    if ($PSCmdlet.ParameterSetName -eq "Private") {
        $Path = "{0}\CredentialStore.json" -f $Env:APPDATA
    }

    # Set latest Credential Store version
    Set-Variable -Name "CSVersion" -Value "1.2.0" -Option Constant

    if (Test-Path $Path) {
        Write-Verbose "CredentialStore in given path found."

        # try tor read the store. Removed the Get-CredentialStore function to avoid recursive calls.
        try {
            $FileContent = Get-Content -Path $Path -Raw
            $CSContent = ConvertFrom-Json $FileContent
        }
        catch {
            Write-Warning "Could not read or convert the given CredentialStore."
            Return $False
        }
        Return $True

    }
    Else {
        Write-Verbose "The given CredentialStore does not exist!"
        Return $False
    }
}
