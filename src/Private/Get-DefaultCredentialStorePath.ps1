function Get-DefaultCredentialStorePath {
    <#
    .SYNOPSIS
        Returns the default CredentialStore path based on the current OS.

    .DESCRIPTION
        This is a low level helper function.

    .INPUTS
        [None]

    .OUTPUTS
        [string]

    .EXAMPLE
        $Path = Get-DefaultCredentialStorePath
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$Shared
    )

    begin {}

    process {
        if ($Shared.IsPresent) {
            if ($IsLinux) {
                return Join-Path -Path '/var/opt' -ChildPath 'PSCredentialStore/CredentialStore.json'
            }
            if ($IsMacOS) {
                return Join-Path -Path '/var/opt' -ChildPath 'PSCredentialStore/CredentialStore.json'
            }
            elseif (($isWindows) -or ($PSVersionTable.PSVersion.Major -lt 6) -or ($PSVersionTable.PSEdition -eq 'Desktop')) {
                return Join-Path -Path $env:ProgramData -ChildPath 'PSCredentialStore/CredentialStore.json'
            }
        }
        else {
            if ($IsLinux) {
                return Join-Path -Path $Env:HOME -ChildPath 'CredentialStore.json'
            }
            if ($IsMacOS) {
                return Join-Path -Path $Env:HOME -ChildPath 'CredentialStore.json'
            }
            elseif (($isWindows) -or ($PSVersionTable.PSVersion.Major -lt 6) -or ($PSVersionTable.PSEdition -eq 'Desktop')) {
                return Join-Path -Path $env:AppData -ChildPath 'CredentialStore.json'
            }
        }
    }

    end {}
}
