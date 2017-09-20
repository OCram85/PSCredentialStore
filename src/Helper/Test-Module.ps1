function Test-Module {
    <#
    .SYNOPSIS
        Tests if the given module exists on the local system.

    .DESCRIPTION
        Tests if the given module is installed on the local system. It returns a bool value as result.

    .PARAMETER Name
        Define a item name you need to test

    .PARAMETER Type
        Define the dependency type. This could be a Module or PSnapin.

    .PARAMETER MessagePattern
        You an optionally adjust the message pattern for the error message itself.
        The available placeholders are:
        - {0} : Type
        - {1} : Name

    .PARAMETER StopIfFails
        This switch forces the entire script to stop if the given dependency object fails.

    .INPUTS
        [None]

    .OUTPUTS
        [Bool]

    .EXAMPLE
        .\Test-Dependency -Name 'VMware.PowerCLI' -Type 'Module'

    .EXAMPLE
        .\Test-Dependency -Name 'VMware.PowerCLI' -Type 'Module' -StopIfFails

    .NOTES
        File Name   : Get-RandomKey.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Module', 'PSSnapin', 'Custom')]
        [string]$Type = 'Module',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$MessagePattern = @"
Could not find the required {0} called {1}. Please install the required {0} to run this function!
"@,
        [Parameter(Mandatory = $false)]
        [switch]$StopIfFails
    )
    begin {

    }

    process {
        $Message = $MessagePattern -f $Type, $Name
        Write-Debug $Message
        switch ($Type) {
            'Module' {
                if (Get-Module -Name $Name -ListAvailable) {
                    return $true
                }
                else {
                    if ($StopIfFails) {
                        Write-Error -Message $Message -ErrorAction Stop -Category NotInstalled
                    }
                    return $false
                }
            }

            'PSSnapin' {
                if (Get-PSSnapin -Name $Name -Registered) {
                    return $true
                }
                else {
                    if ($StopIfFails) {
                        Write-Error -Message $Message -ErrorAction Stop -Category NotInstalled
                        return $false
                    }
                }
            }

            'Custom' {
                Throw 'Custom tests are not implemented yet!'
            }
        }
    }

    end {

    }
}
