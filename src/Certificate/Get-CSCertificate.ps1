function Get-CSCertificate {
    <#
    .SYNOPSIS
        Returns the current used valid PfX Certificate.

    .DESCRIPTION
        Use this function to get the available pfx certficate respecting the config hierarchy.

    .PARAMETER Type
        Select the current credential store type.

    .PARAMETER Thumbprint
        Provice the crednetials thumbprint for the search.

    .INPUTS
        [None]

    .OUTPUTS
        [System.Security.Cryptography.X509Certificates.X509Certificate2]

    .EXAMPLE
        Get-CSCertificate -Type 'Shared' -Thumbprint '12334456'

    .NOTES
        File Name   : Get-CSCertificate.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding()]
    [OutputType([System.Security.Cryptography.X509Certificates.X509Certificate2])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Private', 'Shared')]
        [string]$Type,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Thumbprint
    )

    begin {
    }
    process {
        if ($Type -eq 'Private') {
            Get-CSPfXCertificate -Thumbprint $Thumbprint -StoreName 'My' -StoreLocation 'CurrentUser'
        }
        elseif ($Type -eq 'Shared') {
            if ( $isLinux) {
                $cert = Get-CSPfxCertificate -Thumbprint $Thumbprint -StoreName 'My' -StoreLocation 'CurrentUser'
                if ($null -eq $cert) {
                    Get-CSPfxCertificate -Thumbprint $Thumbprint -StoreName 'Root' -StoreLocation 'LocalMachine'
                }
                else {
                    Write-Output $cert
                }
            }
            elseif ( (! $isLinux) -or ($isWindows) ) {
                $cert = Get-CSPfxCertificate -Thumbprint $Thumbprint -StoreName 'My' -StoreLocation 'LocalMachine'
                if ($null -eq $cert) {
                    Get-CSPfxCertificate -Thumbprint $Thumbprint -StoreName 'Root' -StoreLocation 'LocalMachine'
                }
                else {
                    Write-Output $cert
                }
            }
        }
    }
    end {
    }
}
