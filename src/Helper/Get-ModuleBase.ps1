function Get-ModuleBase {
    <#
    .SYNOPSIS
        Returns the base path of the current module.

    .DESCRIPTION
        This is just a wrapper for enabling pester tests.


    .OUTPUTS
        Returns the base path as string

    .NOTES
        File Name   : Get-ModuleBase.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
#>
    [CmdletBinding()]
    [OutputType()]
    param()
    begin {}
    process {
        return $MyInvocation.MyCommand.Module.ModuleBase
    }
    end {}
}
