function Import-CSCertificate {
    <#
    .SYNOPSIS
        adds a given pfx certificate file to current uerers personal certificate store.

    .DESCRIPTION
        This function is used to import existing pfx certificate files. The Import-PFXCertificate cmdle from the
        PKI module imports the certficate into a deprecated store. Thus you can't read the private key afterwards or
        using it for decrypting data.

    .PARAMETER Path
        Path to an existing *.pfx certificate file.

    .PARAMETER StoreName
        Additionally you change change the store where you want the certificate into.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        Import-CSCertificate -Path (Join-Path -Path $Env:APPDATA -ChildPath '/PSCredentialStore.pfx')

    .NOTES
        File Name   : Import-CSCertificate.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

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
        [string]$StoreLocation = 'CurrentUser',

        [Parameter(Mandatory = $false)]
        [ValidateSet(
            'ReadOnly',
            'ReadWrite',
            'MaxAllowed',
            'OpenExistingOnly',
            'InclueArchived'
        )]
        [string]$OpenFlags = 'ReadWrite'
    )
    begin {
        $Store = [System.Security.Cryptography.X509Certificates.X509Store]::new($StoreName, $StoreLocation)
        try {
            $Store.Open($OpenFlags)
        }
        catch {
            $_.Exception.Message | Write-Error -ErrorAction Stop
        }
    }
    process {
        try {
            $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new()
            $cert.Import(
                $Path,
                $null,
                (
                    [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable -bor
                    [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet
                )
            )

            if (Test-CSCertificate -Thumbprint $cert.Thumbprint) {
                Write-Warning -Message ('The certificate with thumbprint {0} is already present!' -f $cert.Thumbprint)
            }
            else {
                $Store.Add($cert)
            }
        }
        catch {
            $_.Exception.Message | Write-Error
            $ErrorParams = @{
                ErrorAction = 'Stop'
                Exception   = [System.Exception]::new(
                    'Could not read or add the pfx certificate!'
                )
            }
            Write-Error @ErrorParams
        }
    }
    end {
        $Store.Close()
    }
}
