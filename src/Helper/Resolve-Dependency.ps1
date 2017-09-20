function Resolve-Dependency {
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    begin {
        $ModuleRootDir = $MyInvocation.MyCommand.Module.ModuleBase
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
