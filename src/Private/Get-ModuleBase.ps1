function Get-ModuleBase {
    <#
    .SYNOPSIS
        Returns the base path of the current module.

    .DESCRIPTION
        This is just a wrapper for enabling pester tests.

    .OUTPUTS
        Returns the base path as string
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param ()
    begin {}
    process {
        return $MyInvocation.MyCommand.Module.ModuleBase
    }
    end {}
}
