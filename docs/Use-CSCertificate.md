# Use-CSCertificate

## SYNOPSIS
Links an existing PFX Certificate to a CredentialStore.

## SYNTAX

### Private (Default)
```
Use-CSCertificate -Path <String> [-UseCertStore] [<CommonParameters>]
```

### Shared
```
Use-CSCertificate -Path <String> [-CredentialStore <String>] [-Shared] [-UseCertStore] [<CommonParameters>]
```

## DESCRIPTION
Linking a certificate is needed if you plan to use the same CredentialStore in cross platform scenarios.

## EXAMPLES

### BEISPIEL 1
```
Use-CSCertificate -Path 'C:\cert.pfx'
```

## PARAMETERS

### -CredentialStore
Specify a custom path for a shared credential store.

```yaml
Type: String
Parameter Sets: Shared
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Specify the path to the PFX Certificate you want to link for usage.

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
Use the credential store in shared mode.

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

### -UseCertStore
Use the given certificate and import it into the corresponding certificate store.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [None]
## OUTPUTS

### [None]
## NOTES
File Name   : Use-CSCertificate.ps1
Author      : Marco Blessing - marco.blessing@googlemail.com
Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

