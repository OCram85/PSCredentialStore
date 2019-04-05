function Use-CSCertificate {
    <#
    .SYNOPSIS
        Links an existing PFX Certifiacte to a CredentialStore.

    .DESCRIPTION
        Linking a certificate is needed if you plan to use the same CredentialStore in cross platform scenarios.

    .PARAMETER Path
        Specify the path to the PFX Certificate you want to link for usage.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE


    .NOTES
        File Name   : Use-CSCertificate.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding(DefaultParameterSetName = "Private")]
    [OutputType()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Private")]
        [Parameter(Mandatory = $true, ParameterSetName = "Shared")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [ValidateNotNullOrEmpty()]
        [string]$CredentialStore,

        [Parameter(Mandatory = $true, ParameterSetName = "Shared")]
        [switch]$Shared,

        [Parameter(Mandatory = $false, ParameterSetName = "Private")]
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [Switch]$UseCertStore
    )
    begin { }

    process {
        try {
            # We need to resolve the path to make sure it has the correct platform specific syntax.
            # And it should also exist.
            $validPath = Resolve-Path -Path $Path -ErrorAction Stop
            $PfxCertificate = Get-PfxCertificate -FilePath $validPath -ErrorAction Stop
        }
        catch {
            $_.Exception.Error | Write-Error
            $ErrorParams = @{
                Message     = 'The given PFX certificate does not exist!'
                ErrorAction = 'Stop'
            }
            Write-Error @ErrorParams
        }

        try {
            if ($PSCmdlet.ParameterSetName -eq "Private") {
                $StorePath = Get-DefaultCredentialStorePath
                $CS = Get-CredentialStore
            }
            elseif ($PSCmdlet.ParameterSetName -eq "Shared" ) {
                if (!($PSBoundParameters.ContainsKey('CredentialStore'))) {
                    $StorePath = Get-DefaultCredentialStorePath -Shared
                    $CS = Get-CredentialStore -Shared
                }
                else {
                    $StorePath = $CredentialStore
                    $CS = Get-CredentialStore -Shared -Path $CredentialStore
                }
            }
        }
        catch {
            $_.Exception.Error | Write-Error
            $ErrorParams = @{
                Message     = 'The given CredentialStore does not exist!'
                ErrorAction = 'Stop'
            }
            Write-Error @ErrorParams
        }

        # Lets first check if the thumbprint matches
        if (($CS.Thumbprint -notmatch $PfxCertificate.Thumbprint) -and ($CS.Thumbprint.Length -ne 0)) {
            Write-Warning @"
You are trying to map an unknown certificate.
Make sure you used the same AES keys for encrypting!
"@
        }

        if ($UseCertStore) {
            Import-CSCertificate -Type ($PSCmdlet.ParameterSetName -eq "Private") -Path $Path
            $CS.Thumbprint = $PfxCertificate.Thumbprint
            $CS.PfxCertificate = $null
        }
        else {
            $CS.PfxCertificate = $validPath.Path
        }
        $CS | ConvertTo-Json -Depth 5 | Out-File -FilePath $StorePath -Force -Encoding utf8
    }

    end { }
}
