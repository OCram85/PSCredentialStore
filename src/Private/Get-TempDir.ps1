function Get-TempDir {
    <#
    .SYNOPSIS
        Returns the valid temp dir of the current OS

    .DESCRIPTION
        Returns the valid temp dir of the current OS.

    .INPUTS
        [None]
    .OUTPUTS
        [string]

    .EXAMPLE
        Get-TempDir
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param ()

    begin {}
    
    process {
        if ($IsLinux) {
            return (Resolve-Path -Path '/tmp/').Path
        }
        if ($IsMacOS) {
            return (Resolve-Path -Path '/tmp/').Path
        }
        elseif (($isWindows) -or ($PSVersionTable.PSVersion.Major -lt 6) -or ($PSVersionTable.PSEdition -eq 'Desktop')) {
            return (Resolve-Path -Path $env:TEMP).Path
        }
    }
    end {
    }
}
