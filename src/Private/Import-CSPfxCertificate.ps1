function Import-CSPfxCertificate {
    <#
    .SYNOPSIS
        Adds a given pfx certificate file to current user's personal certificate store.

    .DESCRIPTION
        This function is used to import existing pfx certificate files. The Import-PFXCertificate cmdlet from the
        PKI module imports the certificate into a deprecated store. Thus you can't read the private key afterwards or
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
        Import-CSPfxCertificate -Path (Join-Path -Path $Env:APPDATA -ChildPath '/PSCredentialStore.pfx')
    #>

    [CmdletBinding()]
    param (
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
            'IncludeArchived'
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
            $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new(
                $Path,
                $null,
                (
                    [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable -bor
                    [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet
                )
            )

            if (Test-CSPfxCertificate -Thumbprint $cert.Thumbprint) {
                Write-Warning -Message ('The certificate with thumbprint {0} is already present!' -f $cert.Thumbprint)
            }
            else {
                $Store.Add($cert)
            }
        }
        catch {
            $_.Exception.Message | Write-Error -ErrorAction Stop
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
