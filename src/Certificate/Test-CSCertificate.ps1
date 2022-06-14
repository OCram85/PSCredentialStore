function Test-CSCertificate {
    <#
    .SYNOPSIS
        Tests if the linked certificate is store ein the specified cert stores.

    .DESCRIPTION
        Test-CSCertificate should be an easy high level test for the linked certificate.

    .PARAMETER Type
        Select between 'Private' or 'Shared'.

    .INPUTS
        [None]

    .OUTPUTS
        [bool]

    .EXAMPLE
        Test-CSCertificate -Type 'Shared'
    #>

    [CmdletBinding()]
    [OutputType([boolean])]
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
            Write-Warning 'There is a Pfx certificate file linked in the store. Certificates saved in the Cert store will be ignored!'
        }

    }
    process {
        if ($Type -eq 'Private') {
            $cert = Get-CSPfXCertificate -Thumbprint $CS.Thumbprint -StoreName 'My' -StoreLocation 'CurrentUser'
        }
        elseif ($Type -eq 'Shared') {
            if ( $isLinux) {
                $cert = Get-CSPfxCertificate -Thumbprint $CS.Thumbprint -StoreName 'My' -StoreLocation 'CurrentUser'
                if ($null -eq $cert) {
                    $cert = Get-CSPfxCertificate -Thumbprint $CS.Thumbprint -StoreName 'Root' -StoreLocation 'LocalMachine'
                }
            }
            elseif ( (! $isLinux) -or ($isWindows) ) {
                $cert = Get-CSPfxCertificate -Thumbprint $CS.Thumbprint -StoreName 'My' -StoreLocation 'LocalMachine'
                if ($null -eq $cert) {
                    $cert = Get-CSPfxCertificate -Thumbprint $CS.Thumbprint -StoreName 'Root' -StoreLocation 'LocalMachine'
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
