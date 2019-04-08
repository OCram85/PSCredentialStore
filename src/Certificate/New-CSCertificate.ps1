function New-CSCertificate {
    <#
    .SYNOPSIS
        Creates a new PFX certificate for the CredentialStore encryption.

    .DESCRIPTION
        Use this function to create a custom self signed certificate used by the PSCredentialStore module.

    .PARAMETER CRTAttribute
        Provide certificate related attributes provided by function New-CRTAttribute.

    .PARAMETER KeyName
        Provide a custom full path and name for the private key. The file extension has to be `*.key`.

    .PARAMETER CertName
        Provide a custom full path and name for the PFX certificate file. The file extension has to be `*.pfx`

    .INPUTS
        [PSCredentialStore.Certificate.Attribute]

    .OUTPUTS
        [None]

    .EXAMPLE
        New-CSCertificate -CRTAttribute $CRTAttribute -KeyName './myprivate.key' -CertName './mycert.pfx'

    .NOTES
        - File Name   : New-CSCertificate.ps1
        - Author      : Marco Blessing - marco.blessing@googlemail.com
        - Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [PSTypeName('PSCredentialStore.Certificate.Attribute')]$CRTAttribute,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$KeyName = './private.key',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$CertName = './certificate.pfx'
    )

    begin {
        $ModuleBase = Get-ModuleBase
        if ($isLinux -or $isMacOS) {
            try {
                $openssl = Get-Command -Name 'openssl' -ErrorAction Stop
            }
            catch {
                $_.Exception.Message | Write-Error
                $ErrorParams = @{
                    Message     = 'Can not find the openssl binary!'
                    ErrorAction = 'Stop'
                    Exception   = [System.IO.FileNotFoundException]::new()
                }
                Write-Error @ErrorParams
            }
        }
        elseif (($PSVersionTable.PSEdition -eq 'Desktop' -and $PSVersionTable.PSVersion.Major -lt 6) -or ($IsWindows -eq $true)) {
            $openssl = Join-Path -Path $ModuleBase -ChildPath '/Vendor/libressl255/openssl.exe'
        }

        $Env:OPENSSL_CONF = Join-Path $ModuleBase -ChildPath '/openssl.conf'
    }
    process {
        $SubjPattern = "/C={0}/ST={1}/L={2}/O={3}/OU={4}/CN={5}"
        $SubjValues = @(
            $CRTAttribute.Subject.Country,
            $CRTAttribute.Subject.State,
            $CRTAttribute.Subject.City,
            $CRTAttribute.Subject.Organization,
            $CRTAttribute.Subject.OrganizationalUnitName,
            $CRTAttribute.Subject.CommonName
        )
        $Subj = $SubjPattern -f $SubjValues

        $PEMCertName = $CertName -replace '.pfx', '.crt'
        $ExpPattern = '& ''{0}'' req -x509 -sha256 -nodes -days {1} -newkey rsa:2048 -keyout {2} -out {3} -subj "{4}" *>$null'
        $ExpValues = @(
            $openssl,
            $CRTAttribute.Days
            $KeyName,
            $PEMCertName,
            $Subj
        )
        $PEMExp = $ExpPattern -f $ExpValues

        Write-Verbose -Message ( 'Expr string is: {0}' -f $PEMExp)

        # Edit the Error action for the openSLL command to make the redirect *>$null work.
        # There is always a stderr and stdout stream!
        $EAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        Invoke-Expression -Command $PEMExp
        $ErrorActionPreference = $EAP

        # manually testing the openssl command results

        if (! (Test-Path -Path $KeyName)) {
            $ErrorParams = @{
                Message     = 'Could not create the private key ${0}' -f $KeyName
                ErrorAction = 'Stop'
                Exception   = [System.UnauthorizedAccessException]::new()
            }
            Write-Error @ErrorParams
        }
        if (! (Test-Path -Path $PEMCertName)) {
            $ErrorParams = @{
                Message     = 'Could not create the PEM certificate ${0}' -f $PEMCertName
                ErrorAction = 'Stop'
                Exception   = [System.Exception]::new()
            }
            Write-Error @ErrorParams
        }

        $PfxPattern = '& ''{0}'' pkcs12 -export -out {1} -inkey {2} -in {3} -passout pass:'
        $PfxValues = @(
            $openssl,
            $CertName,
            $KeyName,
            ($CertName -replace '.pfx', '.crt')
        )
        $PfxExp = $PfxPattern -f $PfxValues
        Write-Verbose -Message ( 'PfxExp string is: {0}' -f $PfxExp)
        Invoke-Expression -Command $PfxExp

        # Remove private key and crt file. Always ask user
        Remove-Item -Path $KeyName
        Remove-Item -Path ($CertName -replace '.pfx', '.crt')
    }
    end {
        Remove-Item Env:\OPENSSL_CONF -Confirm:$False -Force -ErrorAction SilentlyContinue
    }
}
