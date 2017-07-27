Function Set-ChallengeFile() {
    <#
    .SYNOPSIS
        Writes the given key into the challenge file

    .DESCRIPTION
        You can use the file content for ConvertTo-SecureString operations.

    .PARAMETER Path
        The file you wish to create.

    .PARAMETER KeySize
        Specify the key size for the encryption key.

    .PARAMETER Force
        Use this switch to override an older file version.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        .\Set-ChallengeFile -Path "C:\TMP\myfile.json" -Force

    .NOTES
        File Name   : Set-ChallengeFile.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Path = "{0}\PSCredentialStore\Challenge.bin" -f $env:ProgramData,

        [Parameter(Mandatory = $false)]
        [ValidateSet(16, 24, 32)]
        [string]$KeySize = "24",

        [switch]$Force
    )

    if ((Test-Path -Path $Path)) {
        if ($Force -eq $true) {
            Remove-Item -Path $Path -Confirm:$false -Force
        }
        else {
            Write-Error "The given file already exists!. Use the -Force switch to override it." -ErrorAction Stop
        }
    }
    $PSCredentialStoreDataDir = Split-Path -Path $Path -Parent
    if (-not (Test-Path $PSCredentialStoreDataDir)) {
        try {
            New-Item -ItemType Directory -Path $PSCredentialStoreDataDir
        }
        catch {
            Write-Error ("Could not create the parent data dir {0}" -f $PSCredentialDataDir) -ErrorAction Stop
        }
    }
    try {
        $Keys = Get-RandomKey -Size $KeySize
        [io.file]::WriteAllBytes($Path, $Keys)
    }
    catch {
        $_.Exception | Format-List -Force | Out-String | Write-ErrorErrorAction Stop
    }
}
