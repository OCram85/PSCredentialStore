function Get-RandomKey {
    <#
    .SYNOPSIS
        Returns a random key

    .DESCRIPTION
        You can use the key for further use with SecureStrings.

    .PARAMETER Size
        Define the key size. You can choose between 16, 24 and 32

    .INPUTS
        [None]

    .OUTPUTS
        Returns a Random key as [Byte[]] array.

    .EXAMPLE
        .\Get-RandomKey -Size 24

    .NOTES
        File Name   : Get-RandomKey.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet(16, 24, 32)]
        [string]$size
    )
    # Init the vars
    [Byte[]]$Key = @()
    $i = 0

    while ($i -ne $size) {
        $element = Get-Random -Minimum 0 -Maximum 255
        Write-Debug ("The current element is {0}." -f $element)
        $Key += $element
        $i++
    }
    $Key
}
