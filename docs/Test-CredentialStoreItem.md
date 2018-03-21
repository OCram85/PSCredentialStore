---
external help file: PSCredentialStore-help.xml
Module Name: PSCredentialStore
online version: https://github.com/OCram85/PSCredentialStore
schema: 2.0.0
---

# Test-CredentialStoreItem

## SYNOPSIS
Checks if the given RemoteHost identifier combination exists in the credential store.

## SYNTAX

### Private (Default)
```
Test-CredentialStoreItem -RemoteHost <String> [-Identifier <String>] [<CommonParameters>]
```

### Shared
```
Test-CredentialStoreItem [-Path <String>] -RemoteHost <String> [-Identifier <String>] [-Shared]
 [<CommonParameters>]
```

## DESCRIPTION
Use this cmdlet for basic checks with a single item.
Check the item first with this function before
you try to interact with it.

## EXAMPLES

### EXAMPLE 1
```
If (Test-CredentialStoreItem -RemoteHost "Default") {
```

Get-CredentialStoreItem -RemoteHost "Default"
}
Else {
    Write-Warning ("The given Remote Host {0} does not exist in the credential Store!" -f $RemoteHost)
}

## PARAMETERS

### -Identifier
Adds an optional identifier to the given RemoteHost.
Makes it possible to store multiple credentials
for a single host.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Define a custom credential store you try to read from.
Without the \`-Path\` parameter
\`Test-CredentialStoreItem\` tries to read from the default private store.

```yaml
Type: String
Parameter Sets: Shared
Aliases:

Required: False
Position: Named
Default value: "{0}\PSCredentialStore\CredentialStore.json" -f $env:ProgramData
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoteHost
Specify the host, for which you would like to change the credentials.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Shared
Switch to shared mode with this param.
This enforces the command to work with a shared CredentialStore which
can be decrypted across systems.

```yaml
Type: SwitchParameter
Parameter Sets: Shared
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [None]

## OUTPUTS

### [None]

## NOTES
\`\`\`
File Name   : Test-CredentialStoreItem.ps1
Author      : Marco Blessing - marco.blessing@googlemail.com
Requires    :
\`\`\`

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

