function Test-CSConnection {
    <#
    .SYNOPSIS
        Returns the connection state of a given type to the remote host.

    .DESCRIPTION
        Use this script to check a connection which was established with the `Connect-To` cmdlet.

    .PARAMETER RemoteHost
        Define the remote host you would like to check.

    .Parameter Type
        Define the connection type you would like to check. See the `Connect-To` documentation
        for valid type values.

    .INPUTS
        [None]

    .OUTPUTS
        [bool]

    .EXAMPLE
        Test-CMConnection -RemoteHost "vcr01.internal.net" -Type VMware

    .NOTES
        - File Name   : Test-CSConnection.ps1
        - Author      : Marco Blessing - marco.blessing@googlemail.com
        - Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RemoteHost,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("CiscoUcs", "FTP", "NetAppFAS", "VMware")]
        [string]$Type
    )

    switch ($Type) {
        'VMware' {
            try {
                $Conn = Get-Variable -Name DefaultVIServer -Scope Global -ErrorAction Stop
            }
            catch [System.Management.Automation.ItemNotFoundException] {
                $MsgParams = @{
                    Message = "There is no open PowerCLI VMware connection bound to 'DefaultVIServer'."
                }
                Write-Verbose @MsgParams
                return $false
            }
            if ($Conn.Value.Name -eq $RemoteHost) {
                if ($Conn.Value.IsConnected) {
                    $MsgParams = @{
                        Message = "'DefaultVIServer' found. Connection to given remote host already established."
                    }
                    Write-Verbose @MsgParams
                    return $True
                }
                else {
                    $MsgParams = @{
                        Message = "'DefaultVIServer' found. RemoteHost matches but the connection is closed."
                    }
                    Write-Verbose @MsgParams
                    return $false
                }
            }
        }

        'CiscoUcs' {
            $MsgParams = @{
                ErrorAction = "Stop"
                Message     = "CiscoUCS connection test is not implemented yet!"
            }
            Write-Error @MsgParams
            return $false
        }

        'FTP' {
            $MsgParams = @{
                ErrorAction = "Stop"
                Message     = "FTP connection test is not implemented yet!"
            }
            Write-Error @MsgParams
            return $false
        }

        'NetAppFAS' {
            $MsgParams = @{
                ErrorAction = "Stop"
                Message     = "NetAppFAS connection test is not implemented yet!"
            }
            Write-Error @MsgParams
            return $false
        }

        # The Default section will never be shown as long as the powershell framework isn't broken.
        Default {
            $MsgParams = @{
                ErrorAction = "Stop"
                Message     = "Panic: There is an invalid type value! This error should never be thrown."
            }
            Write-Error @MsgParams
            return $false
        }
    }
}
