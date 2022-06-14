function Get-RandomAESKey {
    <#
    .SYNOPSIS
        Generate a new 32-byte AES key.

    .DESCRIPTION
        Uses the System.Security.Cryptography namespace for random aes key generation.

    .INPUTS
        [None]

    .OUTPUTS
        [byte[]]

    .EXAMPLE
        .\Get-RandomAESKey
    #>

    [CmdletBinding()]
    [OutputType([byte[]])]
    param ()

    begin {}

    process {
        $key = [byte[]]::new(32)
        $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
        $rng.GetBytes($key)
        Write-Output $key
        if ($null -ne $key) {
            [array]::Clear($key, 0, $key.Length)
        }

    }
    end {}
}
