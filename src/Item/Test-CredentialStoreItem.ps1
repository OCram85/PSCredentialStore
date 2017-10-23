function Test-CredentialStoreItem() {
    <#
    .SYNOPSIS
        Checks if the given RemoteHost identifier combination exists in the credential store.

    .DESCRIPTION
        Use this cmdlet for basic checks with a single item. Check the item first with this function before
        you try to interact with it.

    .PARAMETER Path
        Define a custom credential store you try to read from. Without the `-Path` parameter
        `Test-CredentialStoreItem` tries to read from the default private store.

    .PARAMETER RemoteHost
        Specify the host, for which you would like to change the credentials.

    .PARAMETER Identifier
        Adds an optional identifier to the given RemoteHost. Makes it possible to store multiple credentials
        for a single host.

    .PARAMETER Shared
        Switch to shared mode with this param. This enforces the command to work with a shared CredentialStore which
        can be decrypted across systems.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        If (Test-CredentialStoreItem -RemoteHost "Default") {
            Get-CredentialStoreItem -RemoteHost "Default"
        }
        Else {
            Write-Warning ("The given Remote Host {0} does not exist in the credential Store!" -f $RemoteHost)
        }

    .NOTES
        ```
        File Name   : Test-CredentialStoreItem.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :
        ```

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding(DefaultParameterSetName = "Private")]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [string]$Path = "{0}\PSCredentialStore\CredentialStore.json" -f $env:ProgramData,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RemoteHost,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Identifier,

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [switch]$Shared
    )

    if ($PSCmdlet.ParameterSetName -eq "Private") {
        $Path = "{0}\CredentialStore.json" -f $env:APPDATA
    }

    if ($Identifier -ne "") {
        $CredentialName = $RemoteHost = "{0}/{1}" -f $Identifier, $RemoteHost
    }
    else {
        $CredentialName = $RemoteHost
    }

    if (Test-CredentialStore -Path $Path) {
        $CS = Get-CredentialStore -Path $Path
        $CSMembers = Get-Member -InputObject $CS
        if (($CSMembers.MemberType -eq "NoteProperty") -and ($CSMembers.Name -eq $CredentialName)) {
            return $true
        }
        else {
            return $false
        }
    }
    else {
        $MsgParams = @{
            ErrorAction = "Stop"
            Message = "The given credential store ({0}) does not exist!" -f $Path
        }
        Write-Error @MsgParams
    }
}
