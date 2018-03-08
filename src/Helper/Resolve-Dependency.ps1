function Resolve-Dependency {
    <#
    .SYNOPSIS
        Tests defined optional dependencies and returns the result as bool.

    .DESCRIPTION
        Use this function to test for optional modules. You can use it if you provide functions which needs special
        modules but you don't want to make them required.

        Place a file called Dependency.json in your module root dir. The default format is:

        {
            "Version": 0.1,
            "Mandatory": {},
            "Optional": [
                {
                    "Name": "VMware",
                    "Modules": [
                        "VMware.VimAutomation.Core"
                    ]
                },
                {
                    "Name": "CiscoUCS",
                    "Modules": []
                }
            ]
        }

    .PARAMETER Name
        Select the dependency item name you defined in the dependency.json.
    .INPUTS
        [None]

    .OUTPUTS
        [bool]

    .EXAMPLE
        If (-not (Resolve-Dependency -Name 'VMware')) {
            Write-Error -Message ("Could not resolve the optional dependencies defined for {0}" -f 'VMware') -ErrorAction 'Stop'
        }

    .NOTES
        ```
        File Name   : ResolveDependency.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :
        ```

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    begin {
        $ModuleRootDir = Get-ModuleBase
        $DepFilePath = Join-Path -Path $ModuleRootDir -ChildPath "Dependency.json"
        if (Test-Path -Path $DepFilePath) {
            $Dependency = Get-Content -Path $DepFilePath -Raw -Encoding UTF8 | ConvertFrom-Json
        }
        else {
            Write-Warning ("Could not find the dependency file: {0}" -f $DepFilePath)
        }
        $res = @()
    }

    process {
        $SelectedDependency = $Dependency.Optional | Where-Object {$_.Name -match $Name}

        foreach ($Module in $SelectedDependency.Modules) {
            $res += Test-Module -Name $Module
        }
        if ($res -contains $false) {
            return $false
        }
        else {
            return $true
        }
    }

    end {
    }
}
