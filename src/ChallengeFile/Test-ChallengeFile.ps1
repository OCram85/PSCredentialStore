function Test-ChallengeFile {
    <#
    .SYNOPSIS
        Simple path check for challenge file needed by the CredentialStores.

    .DESCRIPTION
        This is supposed to be a internal function to check the existence for a challenge file.

    .PARAMETER Path
        Specify the path to the challenge file.

    .INPUTS
        [None]

    .OUTPUTS
        [Bool].

    .EXAMPLE
        If (Test-ChallengeFile) {
            Write-Host "The file exists."
        }
        Else {
            Write-Warning "Couldn't find the given file!"
        }

    .NOTES
        File Name   : Test-ChallengeFile.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$Path = "{0}\PSCredentialStore\Challenge.bin" -f $env:ProgramData
    )

    if (Test-Path $Path) {
        $true
    }
    else {
        $false
    }
}
