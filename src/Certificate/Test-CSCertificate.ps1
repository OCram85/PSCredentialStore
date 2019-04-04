function Test-CSCertificate {
    <#
    .SYNOPSIS
        Tests if the given certificate exists in a store.

    .DESCRIPTION
        Use this function to ensure if a certificate is already imported into a given store.

    .PARAMETER Thumbprint
        Provide one or more thumprints.

    .PARAMETER StoreName
        Select the store name in which you want to search the certificates.

    .PARAMETER StoreLocation
        Select between the both available locations CurrentUser odr LocalMachine.

    .INPUTS
        [None]

    .OUTPUTS
        [bool]

    .EXAMPLE
        Test-CSCertificate -Thumbprint '12345678' -StoreName 'My' -StoreLocation 'CurrentUser'

    .NOTES
        File Name   : Test-CSCertificate.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Thumbprint,

        [Parameter(Mandatory = $false)]
        [ValidateSet(
            'AddressBook',
            'AuthRoot',
            'CertificateAuthority',
            'Disallowed',
            'My',
            'Root',
            'TrustedPeople',
            'TrustedPublisher'
        )]
        [string]$StoreName = 'My',

        [Parameter(Mandatory = $false)]
        [ValidateSet(
            'CurrentUser',
            'LocalMachine'
        )]
        [string]$StoreLocation = 'CurrentUser'
    )

    begin {
        $Store = [System.Security.Cryptography.X509Certificates.X509Store]::New($StoreName, $StoreLocation)
        try {
            $Store.Open('ReadOnly')
        }
        catch {
            $_.Exception.Message | Write-Error -ErrorAction Stop
        }
    }

    process {
        $Cert = $Store.Certificates | Where-Object { $_.Thumbprint -eq $Thumbprint }

        if ($null -eq $Cert) {
            return $false
        }
        else {
            return $true
        }
    }
    end {
        $Store.Close()
    }
}
