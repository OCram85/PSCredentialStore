function New-CRTAttribute {
    <#
    .SYNOPSIS
        Create required data for a certificate signing request.

    .DESCRIPTION
        Defines the certificate related properties for an upcoming New-PfxCertificate execution.

    .PARAMETER Country
        Provide a two letter country code.

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

    .PARAMETER CSRSubject
        you can provide the needed certificate properties with in one hashtable. This hashtable has to contain the
        following keys: 'Country', 'State', 'City', 'Organization', 'OrganizationalUnitName', 'CommonName'.

    .INPUTS
        [None]

    .OUTPUTS
        ['PSCredentialStore.Certificate.CSRDetails']

    .EXAMPLE
        New-CRTAttribute -CSRSubject @{Country = 'DE'; State = 'BW'; City = 'Karlsruhe'; Organization = 'AwesomeIT'; OrganizationalUnitName = '';CommonName = 'MyPrivateCert'}

    .NOTES
        File Name   : New-CSRDetails.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding()]
    [OutputType('PSCredentialStore.Certificate.Attribute')]
    param(
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
    begin {

    }
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
    end {
    }
}
