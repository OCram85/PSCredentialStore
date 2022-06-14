function New-CSCertAttribute {
    <#
    .SYNOPSIS
        Creates required data for a certificate signing request.

    .DESCRIPTION
        Defines the certificate related properties for an upcoming New-PfxCertificate execution.

    .PARAMETER Country
        County code like EN, DE, IT, FR...

    .PARAMETER State
        Certificate state value.

    .PARAMETER City
        Certificate city value.

    .PARAMETER Organization
        Certificate organization value.

    .PARAMETER OrganizationalUnitName
        Certificate OrganizationalUnitName value.

    .PARAMETER CommonName
        The certificate common name.

    .PARAMETER Days
        The validation time itself.

    .INPUTS
        [None]

    .OUTPUTS
        [PSCredentialStore.Certificate.CSRDetails]

    .EXAMPLE
        New-CSCertAttribute -Country 'DE' -State 'BW' -City 'Karlsruhe' -Organization 'AwesomeIT' -OrganizationalUnitName '' -CommonName 'MyPrivateCert'
    #>

    [CmdletBinding()]
    [OutputType('PSCredentialStore.Certificate.Attribute')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateLength(2, 2)]
        [ValidateNotNull()]
        [string]$Country,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$State,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$City,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$OrganizationalUnitName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$CommonName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [int]$Days = 365
    )
    begin {}

    process {
        return [PSCustomObject]@{
            PSTypeName = 'PSCredentialStore.Certificate.Attribute'
            Subject    = [PSCustomObject]@{
                PSTypeName             = 'PSCredentialStore.Certificate.Attribute.Subject'
                Country                = $Country
                State                  = $State
                City                   = $City
                Organization           = $Organization
                OrganizationalUnitName = $OrganizationalUnitName
                CommonName             = $CommonName
            }
            Days       = $Days
        }
    }
    end {}
}
