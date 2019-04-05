function Import-CSCertificate {
    <#
    .SYNOPSIS
        A brief description of the function or script.

    .DESCRIPTION
        Describe the function of the script using a single sentence or more.

    .PARAMETER One
        Description of the Parameter (what it does)

    .INPUTS
        Describe the script input parameters (if any), otherwise it may also list the word "[None]".

    .OUTPUTS
        Describe the script output parameters (if any), otherwise it may also list the word "[None]".

    .EXAMPLE
        .\Remove-Some-Script.ps1 -One content

    .NOTES
        File Name   : Import-CSCertificate.ps1
        Author      : fullname - mail
        Requires    : ModuleNames

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Private', 'Shared')]
        [string]$Type,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]$Path

    )
    begin {
        if (! (Test-Path -Path $Path)) {
            $ErrorParams = @{
                ErrorAction = 'Stop'
                Exception   = [System.Exception]::new(
                    ('File {0} not found!') -f $Path
                )
            }
            Write-Error @ErrorParams
        }
    }

    process {
        # Import to CurrentUser\My stor for windows and linux
        if ($Type -eq 'Private') {
            Import-CSPfxCertificate -Path $Path -StoreName 'My' -StoreLocation 'CurrentUser' -OpenFlags 'ReadWrite'
        }
        elseif ( (! $isLinux ) -and ($Type -eq 'Shared') ) {
            Import-CSPfxCertificate -Path $Path -StoreName 'My' -StoreLocation 'CurrentUser' -OpenFlags 'ReadWrite'
        }
        elseif ( ($isLinux) -and ($Type -eq 'Shared') ) {
            Import-CSPfxCertificate -Path $Path -StoreName 'My' -StoreLocation 'LocalMachine' -OpenFlags 'ReadWrite'
        }
    }
    end {
    }
}
