---
external help file: PSCredentialStore-help.xml
Module Name: PSCredentialStore
online version: https://github.com/OCram85/PSCredentialStore
schema: 2.0.0
---

# New-CredentialStore

## SYNOPSIS
Creates a new credential store File

## SYNTAX

### Private (Default)
```
New-CredentialStore [-Force] [<CommonParameters>]
```

### Shared
```
New-CredentialStore [-Shared] [-Path <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
You need to run this script first to create a new credential store before you try to
save new credentials with New-CredentialStoreItem.

## EXAMPLES

### EXAMPLE 1
```
New-CredentialStore
```

# Creates a new private CredentialStore

### EXAMPLE 2
```
New-CredentialStore -Force
```

# Resets an existing private CredentialStore

### EXAMPLE 3
```
New-CredentialStore -Shared
```

# Creates a new shared CredentialStore

### EXAMPLE 4
```
New-CredentialStore -Shared -Path "C:\TMP\CredentialStore.json"
```

# Creates a new shared CredentialStore in the given location.

## PARAMETERS

### -Force
Use this switch to reset an existing store.
The complete content will be wiped.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Define a location for the new shared CredentialStore.
The default store will be created in
$Env:ProgramData\PSCredentialStore dir.

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
Creates a CredentialStore in the Shared mode.
This enables you to read the CredentialStore Items on
different systems or profiles.
In addition you can optionally provide a custom path wit the -Path parameter.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [None]

## OUTPUTS

### [None]

## NOTES
\`\`\`
File Name   : New-CredentialStore.ps1
Author      : Marco Blessing - marco.blessing@googlemail.com
Requires    :
\`\`\`

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

