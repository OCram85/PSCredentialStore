# New-CredentialStore

## SYNOPSIS
Creates a new credential store File

## SYNTAX

### Private (Default)
```
New-CredentialStore [-Force] [-PassThru] [-SkipPFXCertCreation] [-UseCertStore] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Shared
```
New-CredentialStore [-Shared] [-Path <FileInfo>] [-Force] [-PassThru] [-SkipPFXCertCreation] [-UseCertStore]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
You need to run this script first to create a new credential store before you try to
save new credentials with New-CredentialStoreItem.

## EXAMPLES

### BEISPIEL 1
```
New-CredentialStore
```

# Creates a new private CredentialStore

### BEISPIEL 2
```
New-CredentialStore -Force
```

# Resets an existing private CredentialStore

### BEISPIEL 3
```
New-CredentialStore -Shared
```

# Creates a new shared CredentialStore

### BEISPIEL 4
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

### -PassThru
{{ Fill PassThru Description }}

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
Type: FileInfo
Parameter Sets: Shared
Aliases:

Required: False
Position: Named
Default value: None
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

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipPFXCertCreation
You can skip the pfx certificate creation process.
This makes sense if you have a previously created cert or want to
import a cert in cross-platform environments.

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

### -UseCertStore
Instead of using a plain pfx file beside your CredentialStore file you can import it into the user or machine
certificate store.
In this case the system itself secures the cert and you don't hat to set custom NTFS
permissions so secure your shared certificate.

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

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [None]
## OUTPUTS

### ['PSCredentialStore.Store'] Returns the recently created CredentialStore object if the -PassThru parameter
### was given.
## NOTES
- File Name   : New-CredentialStore.ps1
- Author      : Marco Blessing - marco.blessing@googlemail.com
- Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

