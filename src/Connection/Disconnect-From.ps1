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
        Specify the host type of the target. Currently implemented targets are: CiscoUcs, FTP, NetAppFAS, VMware,
        CisServer, ExchangeHTTP, ExchangeHTTPS, SCP.

    .PARAMETER Force
        Force the disconnect, even if the disconnect would fail.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        Disconnect-From -RemoteHost "ucs.myside.local" -Type CiscoUcs

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
            'FTP',
            'NetAppFAS',
            'VMware',
            'CisServer',
            'ExchangeHTTP',
            'ExchangeHTTPS',
            'SCP'
        )]
        [string]$Type,

        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    switch -Regex ($Type) {
        "VMware" {
            try {
                if ($Force) {
                    Disconnect-VIServer -Server $RemoteHost -Confirm:$false -ErrorAction Stop -Force:$true
                }
                else {
                    Disconnect-VIServer -Server $RemoteHost -Confirm:$false -ErrorAction Stop
                }
            }

            catch {
                # Write a error message to the log.
                $MessageParams = @{
                    Message     = "Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type
                    ErrorAction = "Stop"
                }
                Write-Error @MessageParams
            }
        }
        "CisServer" {
            try {
                if ($Force) {
                    Disconnect-CisServer -Server $RemoteHost -Confirm:$false -ErrorAction Stop -Force:$true
                }
                else {
                    Disconnect-CisServer -Server $RemoteHost -Confirm:$false -ErrorAction Stop
                }
            }

            catch {
                # Write a error message to the log.
                $MessageParams = @{
                    Message     = "Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type
                    ErrorAction = "Stop"
                }
                Write-Error @MessageParams
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
                $MessageParams = @{
                    Message     = "Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type
                    ErrorAction = "Stop"
                }
                Write-Error @MessageParams
            }

        }
        "CiscoUcs" {
            try {
                Disconnect-Ucs -Ucs $RemoteHost
            }

            catch {
                # Write a error message to the log.
                $MessageParams = @{
                    Message     = "Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type
                    ErrorAction = "Stop"
                }
                Write-Error @MessageParams
            }
        }
        "ExchangeHTTP*" {
            try {
                Get-Variable -Name 'PSExchangeRemote' -Scope Global -ErrorAction Stop
                Remove-PSSession -Session $Global:PSExchangeRemote -ErrorAction Stop
            }
            catch {
                $MessageParams = @{
                    Message     = "Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type
                    ErrorAction = "Stop"
                }
                Write-Error @MessageParams
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
            $MessageParams = @{
                Message     = "Unable to disconnect from {0} using Type {1}." -f $RemoteHost, $Type
                ErrorAction = "Stop"
            }
            Write-Error @MessageParams
        }
    }
}
