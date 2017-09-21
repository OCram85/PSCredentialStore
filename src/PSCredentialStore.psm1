$Items = (Get-ChildItem -Path ("{0}\*.ps1" -f $PSScriptRoot ) -Recurse ).FullName | Where-Object {
    $_ -notmatch "(Classes|Init)"
}
ForEach ($Item in $Items) {
    # Write-Verbose ("dot sourcing file {0}" -f $Item)
    . $Item
}

# Exports are now controlled by module manifest
# Export-ModuleMember -Function *
