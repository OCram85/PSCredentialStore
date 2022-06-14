#region module-definition

#endregion module-definition
Set-Variable -Name "CSVersion" -Value "2.0.0" -Option Constant -Scope 'Script' -ErrorAction Stop

#region dot-sourcing
# dot-sourcing all module functions. The export is handled via manifest file.

$Items = (Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath '*.ps1') -Recurse ).FullName | Where-Object {
    $_ -notmatch "(Classes|Init)"
}
foreach ($Item in $Items) {
    # Write-Verbose ("dot sourcing file {0}" -f $Item)
    . $Item
}
#endregion dot-sourcing
