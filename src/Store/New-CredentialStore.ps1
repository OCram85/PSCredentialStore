function New-CredentialStore {
    <#
    .SYNOPSIS
        Creates a new credential store File

    .DESCRIPTION
        You need to run this script first to create a new credential store before you try to
        save new credentials with New-CredentialStoreItem.

    .PARAMETER Path
        Define a location for the new shared CredentialStore. The default store will be created in
        $Env:ProgramData\PSCredentialStore dir.

    .PARAMETER Shared
        Creates a CredentialStore in the Shared mode. This enables you to read the CredentialStore Items on
        different systems or profiles. In addition you can optionally provide a custom path wit the -Path parameter.

    .PARAMETER Force
        Use this switch to reset an existing store. The complete content will be wiped.

    .PARAMETER SkipPFXCertCreation
        You can skip the pfx certification process. This makes sense if you have a previously created cert or want to
        import a cert in cross-platform environments.

    .Parameter UseCertStore
        Instead of using a plain pfx file beside your CredentialStore file you can import it into the user or machine
        certification store. In this case the system itself secures the cert and you don't hat to set custom NTFS
        permissions so secure your shared certificate.

    .INPUTS
        [None]

    .OUTPUTS
        ['PSCredentialStore.Store'] Returns the recently created CredentialStore object if the -PassThru parameter
        was given.

    .EXAMPLE
        New-CredentialStore
        # Creates a new private CredentialStore

    .EXAMPLE
        New-CredentialStore -Force
        # Resets an existing private CredentialStore

    .EXAMPLE
        New-CredentialStore -Shared
        # Creates a new shared CredentialStore

    .EXAMPLE
        New-CredentialStore -Shared -Path "C:\TMP\CredentialStore.json"
        # Creates a new shared CredentialStore in the given location.

    .NOTES
        - File Name   : New-CredentialStore.ps1
        - Author      : Marco Blessing - marco.blessing@googlemail.com
        - Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>

    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = "Private")]
    [OutputType("PSCredentialStore.Store")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Shared")]
        [switch]$Shared,

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]$Path,

        [Parameter(Mandatory = $false, ParameterSetName = "Private")]
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [Switch]$Force,

        [Parameter(Mandatory = $false, ParameterSetName = "Private")]
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [Switch]$PassThru,

        [Parameter(Mandatory = $false, ParameterSetName = "Private")]
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [Switch]$SkipPFXCertCreation,

        [Parameter(Mandatory = $false, ParameterSetName = "Private")]
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [Switch]$UseCertStore
    )

    begin {
        # Lets get the current Date in a human readable format.
        $CurrentDate = Get-Date -UFormat "%Y-%m-%d %H:%M:%S"

        # Set latest Credential Store version
        # Set-Variable -Name "CSVersion" -Value "2.0.0" -Option Constant -Scope

        # test if the path input is a valid file path
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Path')) {
            if ($Path.Attributes -contains 'Directory') {
                $ErrorParams = @{
                    ErrorAction = 'Stop'
                    Exception   = [System.IO.InvalidDataException]::new(
                        'Please provide a full path containing the credential store file name with the .json extension!'
                    )
                }
                Write-Error @ErrorParams
            }
            elseif ( ($null -eq $Path.Extension) -or ($Path.Extension -ne '.json')) {
                $ErrorParams = @{
                    ErrorAction = 'Stop'
                    Exception   = [System.IO.InvalidDataException]::new(
                        'Your provided path does not conain the required file extension .json !'
                    )
                }
                Write-Error @ErrorParams
            }
        }
    }

    process {
        # Set the CredentialStore for private, shared or custom mode.
        Write-Debug ("ParameterSetName: {0}" -f $PSCmdlet.ParameterSetName)
        if ($PSCmdlet.ParameterSetName -eq "Private") {
            $Path = Get-DefaultCredentialStorePath
        }
        elseif ($PSCmdlet.ParameterSetName -eq "Shared") {
            if (!($PSBoundParameters.ContainsKey('Path'))) {
                $Path = Get-DefaultCredentialStorePath -Shared
            }
        }

        # Test if in the CredentialStore already exists.
        Write-Verbose "Test if there is already a credential store."
        if ((Test-Path -Path $Path) -and ($Force -ne $true)) {
            $ErrorParams = @{
                ErrorAction = 'Stop'
                Exception   = [System.InvalidOperationException]::new(
                    'The given file already exists. Use the -Force switch to override the existing store.'
                )
            }
            Write-Error @ErrorParams
        }

        if (! $SkipPFXCertCreation.IsPresent) {
            $CRTParams = @{
                Country                = 'DE'
                State                  = 'PSCredentialStore'
                City                   = 'PSCredentialStore'
                Organization           = 'PSCredentialStore'
                OrganizationalUnitName = $PSCmdlet.ParameterSetName
                CommonName             = 'PSCredentialStore'
            }
            $CRTAttribute = New-CSCertAttribute @CRTParams

            # If we are working with a ne shared store we have to create the location first.
            # Otherwise openssl fails with unknown path

            $StoreHome = Split-Path -Path $Path -Parent
            if (! (Test-Path -Path $StoreHome)) {
                New-Item -ItemType Directory -Path $StoreHome -ErrorAction Stop
            }

            $PfxParams = @{
                CRTAttribute = $CRTAttribute
                KeyName      = Join-Path -Path $StoreHome -ChildPath 'private.key'
                CertName     = Join-Path -Path $StoreHome -ChildPath 'PSCredentialStore.pfx'
                ErrorAction  = 'Stop'
                Confirm      = $false
            }

            # test if there is already a cert
            if ((Test-Path $PfxParams.CertName) -and (! $Force.IsPresent)) {
                $ErrorParams = @{
                    Exception   = [System.IO.InvalidDataException]::new(
                        'There is already a PfxCertificate for a private CredentialStore!'
                    )
                    ErrorAction = 'Stop'
                }
                Write-Error @ErrorParams
            }

            try {
                New-CSCertificate @PfxParams
            }
            catch {
                $_.Exception.Message | Write-Error
                $ErrorParams = @{
                    ErrorAction = 'Stop'
                    Exception   = [System.Exception]::new(
                        'Could not create the private PfXCertificate!'
                    )
                }
                Write-Error @ErrorParams
            }

            try {
                $FreshCert = Get-PfxCertificate -FilePath $PfxParams.CertName -ErrorAction Stop
            }
            catch [System.Management.Automation.ItemNotFoundException] {
                $_.Exception.Message | Write-Error
                Write-Error -Message 'Could not read the new PfxCertificate.' -ErrorAction Stop
            }
        }

        # We need to use the IDictionary to keep the property sorting in the object.
        $ObjProperties = [ordered]@{
            PSTypeName     = 'PSCredentialStore.Store'
            Version        = $CSVersion
            Created        = $CurrentDate
            PfxCertificate = $null
            Thumbprint     = $null
            Type           = $null
        }

        if ($PSCmdlet.ParameterSetName -eq "Shared") {
            $ObjProperties.Type = "Shared"
        }
        else {
            $ObjProperties.Type = "Private"
        }

        if (! $SkipPFXCertCreation.IsPresent) {
            $ObjProperties.Thumbprint = $FreshCert.Thumbprint

            if ($UseCertStore.IsPresent) {
                Write-Verbose 'Importing new PFX certificate file...'
                Import-CSCertificate -Type $ObjProperties.Type -Path $PfxParams.CertName
            }
            else {
                $ObjProperties.PfxCertificate = $PfxParams.CertName

            }
        }


        $CredentialStoreObj = [PSCustomObject]$ObjProperties
        try {
            $JSON = ConvertTo-Json -InputObject $CredentialStoreObj -ErrorAction Stop
            $JSON | Out-File -FilePath $Path -ErrorAction Stop -Force
        }
        catch {
            $_.Exception.Message | Write-Error
            $ErrorParams = @{
                ErrorAction = 'Stop'
                Exception   = [System.IO.IOException]::new(
                    'Unable to convert or write the CredentialStore'
                )
            }
            Write-Error @ErrorParams
        }

        if ($PassThru.IsPresent) {
            return $CredentialStoreObj
        }
    }

    end {
    }
}
