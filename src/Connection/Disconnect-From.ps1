function Disconnect-From {
    <#
    .SYNOPSIS
        Terminates a session established with Connect-To using a CredentialStoreItem.

    .DESCRIPTION
        Terminates a session established with Connect-To using a CredentialStoreItem.

    .PARAMETER RemoteHost
        Specify the remote endpoint, whose session you would like to terminate.

    .PARAMETER Identifier
        Defaults to "". Specify a string, which separates two CredentialStoreItems for the
        same hostname.

    .PARAMETER Type
        Specify the host type of the target. Currently implemented targets are:
        - CiscoUcs
        - CiscoUcsCentral
        - CisServer
        - ExchangeHTTP
        - ExchangeHTTPS
        - FTP
        - NetAppFAS
        - SCP
        - VMware

    .PARAMETER Force
        Force the disconnect, even if the disconnect would fail.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        Disconnect-From -RemoteHost "ucs.myside.local" -Type CiscoUcs

    .EXAMPLE
        Disconnect-From -RemoteHost "ucscentral.myside.local" -Type 'CiscoUcsCentral'

    .EXAMPLE
        Disconnect-From -RemoteHost "ftp.myside.local" -Type FTP

    .EXAMPLE
        Disconnect-From -RemoteHost "fas.myside.local" -Type NetAppFAS

    .EXAMPLE
        Disconnect-From -RemoteHost "esx01.myside.local" -Type VMware

    .EXAMPLE
        Disconnect-From -RemoteHost "esx01.myside.local" -Type VMware -Force:$True

    .EXAMPLE
        Disconnect-From -RemoteHost "vcenter.myside.local" -Type CisServer

    .EXAMPLE
        Disconnect-From -RemoteHost "exchange01.myside.local" -Type ExchangeHTTP

    .EXAMPLE
        Disconnect-From -RemoteHost "exchange01.myside.local" -Type ExchangeHTTPS

    .NOTES
        - File Name   : Disconnect-From.ps1
        - Author      : Marco Blessing - marco.blessing@googlemail.com
        - Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RemoteHost,

        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'CiscoUcs',
            'CiscoUcsCentral',
            'CisServer',
            'ExchangeHTTP',
            'ExchangeHTTPS',
            'FTP',
            'NetAppFAS',
            'SCP',
            'VMware'
        )]
        [string]$Type,

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    # Set defaults for the preference variables.
    $InformationPreference = 'Continue'
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'


    switch -Regex ($Type) {
        "VMware" {
            try {
                if ($Force) {
                    Disconnect-VIServer -Server $RemoteHost -Confirm:$false -Force:$true
                }
                else {
                    Disconnect-VIServer -Server $RemoteHost -Confirm:$false
                }
            }

            catch {
                # Write a error message to the log.
                $_.Exception.Message | Write-Warning
                Write-Error -Message ("Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type)
            }
        }
        "CisServer" {
            try {
                if ($Force) {
                    Disconnect-CisServer -Server $RemoteHost -Confirm:$false -Force:$true
                }
                else {
                    Disconnect-CisServer -Server $RemoteHost -Confirm:$false
                }
            }

            catch {
                # Write a error message to the log.
                $_.Exception.Message | Write-Warning
                Write-Error -Message ("Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type)
            }
        }
        # Check for an existing WinSCP Session var
        "FTP" {
            if ($Global:WinSCPSession.Opened) {
                Remove-WinSCPSession -WinSCPSession $Global:WinSCPSession
            }
            else {
                $MessageParams = @{
                    Message     = "There is no open WinSCP Session"
                    ErrorAction = "Stop"
                }
                Write-Error @MessageParams
            }
        }
        # DataONTAP doesn't have a CmdLet `Disconnect-NcController`.
        # So we go ahead and clear the CurrentNcController variable.
        "NetAppFAS" {
            try {
                $MessageParams = @{
                    Message     = "Setting {0} to `$null, which will disconnect NetAppFAS" -f $Global:CurrentNcController
                    ErrorAction = "Continue"
                }
                Write-Verbose @MessageParams
                $Global:CurrentNcController = $null
            }

            catch {
                # Write a error message to the log.
                $_.Exception.Message | Write-Warning
                Write-Error -Message ("Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type)
            }

        }
        "CiscoUcs" {
            try {
                Disconnect-Ucs -Ucs $RemoteHost
            }

            catch {
                # Write a error message to the log.
                $_.Exception.Message | Write-Warning
                Write-Error -Message ("Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type)
            }
        }

        'CiscoUcsCentral' {
            try {
                Disconnect-UcsCentral -Ucs $RemoteHost
            }

            catch {
                # Write a error message to the log.
                $_.Exception.Message | Write-Warning
                Write-Error -Message ('Unable to disconnect from {0} using Type {1}.' -f $RemoteHost, $Type)
            }
        }


        "ExchangeHTTP*" {
            try {
                Get-Variable -Name 'PSExchangeRemote' -Scope Global
                Remove-PSSession -Session $Global:PSExchangeRemote
            }
            catch {
                # Write a error message to the log.
                $_.Exception.Message | Write-Warning
                Write-Error -Message ("Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type)
            }
        }
        "SCP" {
            if ($Global:WinSCPSession.Opened) {
                Remove-WinSCPSession -WinSCPSession $Global:WinSCPSession
            }
            else {
                $MessageParams = @{
                    Message     = "There is no open WinSCP Session"
                    ErrorAction = "Stop"
                }
                Write-Error @MessageParams
            }
        }
        default {
            # Write a error message to the log.
            Write-Error -Message ("Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type)
        }
    }
}
