function Import-CSCertificate {
    <#
    .SYNOPSIS
        Imports a linked certificate to the valid store location.

    .DESCRIPTION
        Import-CSCertificate takes a pfx certificate file and imports it to the supposed certificate store for
        private and shared credential stores.

    .PARAMETER Type
        Select between the a private and shared credential store.

    .PARAMETER Path
        Provide a valid path to pfx certificate file.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        Import-CSCertificate -Type 'Private' -Path (Join-Path -Path $Env:APPDATA -ChildItem 'PfxCertificate.pfx')
    #>

    [CmdletBinding()]
    param (
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
        # Import to CurrentUser\My store for windows and linux
        if ($Type -eq 'Private') {
            Import-CSPfxCertificate -Path $Path -StoreName 'My' -StoreLocation 'CurrentUser' -OpenFlags 'ReadWrite'
        }
        elseif ( (! $isLinux ) -and ($Type -eq 'Shared') ) {
            Import-CSPfxCertificate -Path $Path -StoreName 'My' -StoreLocation 'LocalMachine' -OpenFlags 'ReadWrite'
        }
        elseif ( ($isLinux) -and ($Type -eq 'Shared') ) {
            Import-CSPfxCertificate -Path $Path -StoreName 'My' -StoreLocation 'CurrentUser' -OpenFlags 'ReadWrite'
        }
    }
    end {
    }
}
