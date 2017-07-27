function Get-CredentialStoreItem {
    <#
    .SYNOPSIS
        Returns the Credential from a given remote host item.

    .DESCRIPTION
        Return the credential as PSCredential object.


    .PARAMETER RemoteHost
        Specify the host, for which you would like to change the credentials.

    .PARAMETER Identifier
            Provide a custom identifier to the given remote host key. This enables you to store multiple credentials
            for a single remote host entry. For example ad/sys1, ftp/sys1, mssql/sys1

    .PARAMETER Path
        Define a custom path to a shared CredentialStore.

    .PARAMETER Shared
        Switch to shared mode with this param. This enforces the command to work with a shared CredentialStore which
        can be decrypted across systems.

    .INPUTS
        [None]

    .OUTPUTS
        [System.Management.Automation.PSCredential]

    .EXAMPLE
        $myCreds = Get-CredentialStoreItem -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local"

    .NOTES
        File Name   : Get-CredentialStoreItem.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>

    [CmdletBinding(DefaultParameterSetName = "Private")]
    [OutputType([System.Management.Automation.PSCredential])]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [string]$Path = "{0}\PSCredentialStore\CredentialStore.json" -f $env:ProgramData,

        [Parameter(Mandatory = $true, ParameterSetName = "Shared")]
        [Parameter(Mandatory = $true, ParameterSetName = "Private")]
        [ValidateNotNullOrEmpty()]
        [string]$RemoteHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [Parameter(Mandatory = $false, ParameterSetName = "Private")]
        [ValidateNotNullOrEmpty()]
        [string]$Identifier,

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [switch]$Shared
    )

    # First set a constand path for private CredentialStore mode.
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
        # Let`s first check if the given remote host exists as object property
        if (($CSMembers.MemberType -eq "NoteProperty") -and ($CSMembers.Name -eq $CredentialName)) {
            if ($CS.Type -eq "Private") {
                $CSItem = [ordered]@{
                    User = $CS.$CredentialName.User
                    Password = ConvertTo-SecureString -String $CS.$CredentialName.Password
                }
            }
            else {
                $Key = Get-ChallengeFile
                $CSItem = [ordered]@{
                    User = $CS.$CredentialName.User
                    Password = ConvertTo-SecureString -String $CS.$CredentialName.Password -Key $Key
                }
            }
            New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $CSItem.User, $CSItem.Password
        }
        else {
            $MsgParams = @{
                ErrorAction = "Stop"
                Message = "Could not find credentials for the given remote host: {0}" -f $RemoteHost
            }
            Write-Error @MsgParams
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
