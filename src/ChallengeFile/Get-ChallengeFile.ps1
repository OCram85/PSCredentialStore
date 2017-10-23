function Get-ChallengeFile {
    <#
    .SYNOPSIS
        Reads the challenge file as binary content.

    .DESCRIPTION
        Use this function to tread a challenge file. Returns a [Byte[]] Array.

    .PARAMETER Path
        Specify a file to read.

    .INPUTS
        [None]

    .OUTPUTS
        [Byte[]]

    .EXAMPLE
        .\Get-RandomKey -Path "C:\TMP\Challenge.bin"

    .NOTES
        ```
        File Name   : Get-ChallengeFile.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :
        ```
    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Path = "{0}\PSCredentialStore\Challenge.bin" -f $env:ProgramData
    )

    if (Test-Path $Path) {
        try {
            [io.file]::ReadAllBytes($Path)
        }
        catch {
            Write-Error ("Could not read file {0}." -f $Path) -ErrorAction Stop
        }
    }
}
