#region module-definition

#endregion module-definition
Set-Variable -Name "CSVersion" -Value "2.0.0" -Option Constant -Scope 'Script' -ErrorAction Stop

# Get all child items in the Script path and exclude the Deploy script (if present.)
$Functions = Get-ChildItem -Path $PSScriptRoot\*.ps1 -Recurse | Where-Object { $_.BaseName -notmatch '.Tests' }

foreach ($Item in $Functions) {
    . $Item.FullName
}
