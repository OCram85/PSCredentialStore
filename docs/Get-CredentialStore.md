---
external help file: PSCredentialStore-help.xml
Module Name: PSCredentialStore
online version: https://github.com/OCram85/PSCredentialStore
schema: 2.0.0
---

# Get-CredentialStore

## SYNOPSIS
Reads the complete content of the credential store and returns it as a new object.

## SYNTAX

### Private (Default)
```
Get-CredentialStore [<CommonParameters>]
```

### Shared
```
Get-CredentialStore [-Path <String>] [-Shared] [<CommonParameters>]
```

## DESCRIPTION
The content is in a raw format.
It means there is no transformation to the different credential types.
You can not use the object properties to connect with remote host.
Therefore please use
Get-CredentialStoreItem.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
$CSContent = Get-CredentialStore -Path "C:\TMP\mystore.json"
```

## PARAMETERS

### -Path
Define a custom path to a shared CredentialStore.

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

### [PSObject] Returns the credential store content as PSObject.

## NOTES
\`\`\`
File Name   : Get-CredentialStore.ps1
Author      : Marco Blessing - marco.blessing@googlemail.com
Requires    :
\`\`\`

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

