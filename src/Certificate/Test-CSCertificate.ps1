function Test-CSCertificate {
    <#
    .SYNOPSIS
        Tests if the linked certificate is stor ein the specified cert stores.

    .DESCRIPTION
        Test-CSCertficate should be an easy high level test for the linked certificate.

    .PARAMETER Type
        Select between 'Private' or 'Shared'.

    .INPUTS
        [None]

    .OUTPUTS
        [bool]

    .EXAMPLE
        .\Remove-Some-Script.ps1 -One content

    .NOTES
        File Name   : Test-CSCertificate.ps1
        Author      : Marco Blessin - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Private', 'Shared')]
        [string]$Type
    )
    begin {
        if ($Type -eq 'Private') {
            $CS = Get-CredentialStore
        }
        elseif ($Type -eq 'Shared') {
            $CS = Get-CredentialStore -Shared
        }
        if ($null -ne $CS.PfxCertificate) {
            Write-Warning 'There is a Pfx certificate file linked in the store. Certifcates saved in the Cert store will be ignored!'
        }

    }
    process {
        if ($Type -eq 'Private') {
            $cert = Get-CSPfXCertificate -Thumbprint $Thumbprint -StoreName 'My' -StoreLocation 'CurrentUser'
        }
        elseif ($Type -eq 'Shared') {
            if ( $isLinux) {
                $cert = Get-CSPfxCertificate -Thumbprint $Thumbprint -StoreName 'My' -StoreLocation 'CurrentUser'
                if ($null -eq $cert) {
                    $cert = Get-CSPfxCertificate -Thumbprint $Thumbprint -StoreName 'Root' -StoreLocation 'LocalMachine'
                }
            }
            elseif ( (! $isLinux) -or ($isWindows) ) {
                $cert = Get-CSPfxCertificate -Thumbprint $Thumbprint -StoreName 'My' -StoreLocation 'LocalMachine'
                if ($null -eq $cert) {
                    $cert = Get-CSPfxCertificate -Thumbprint $Thumbprint -StoreName 'Root' -StoreLocation 'LocalMachine'
                }
            }
        }
        if ($null -eq $cert) {
            return $false
        }
        else {
            return $true
        }
    }
    end {
    }
}
