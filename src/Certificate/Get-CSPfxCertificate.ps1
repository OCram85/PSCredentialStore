function Get-CSPfxCertificate {
    <#
    .SYNOPSIS
        Returns the certificate object given by thumbprint.

    .DESCRIPTION
        You can use this function to get a stored certificate. Search for the object by its unique thumbprint.

    .PARAMETER Thumbprint
        Provide one or more thumprints.

    .PARAMETER StoreName
        Select the store name in which you want to search the certificates.

    .PARAMETER StoreLocation
        Select between the both available locations CurrentUser odr LocalMachine.

    .INPUTS
        [string]

    .OUTPUTS
        [System.Security.Cryptography.X509Certificates.X509Certificate2[]]

    .EXAMPLE
        Get-CSPfxCertificate -Thumbprint '12345678' -StoreName 'My' -StoreLocation 'CurrentUser'

    .NOTES
        File Name   : Get-CSPfxCertificate.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding()]
    [OutputType([System.Security.Cryptography.X509Certificates.X509Certificate2])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Thumbprint,

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
        foreach ($Thumb in $Thumbprint) {
            Write-Output $Store.Certificates | Where-Object { $_.Thumbprint -eq $Thumb }
        }
    }
    end {
        $Store.Close()
    }
}
