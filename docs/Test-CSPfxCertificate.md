---
external help file: PSCredentialStore-help.xml
Module Name: PSCredentialStore
online version: https://github.com/OCram85/PSCredentialStore
schema: 2.0.0
---

# Test-CSPfxCertificate

## SYNOPSIS
Tests if the given certificate exists in a store.

## SYNTAX

```
Test-CSPfxCertificate [-Thumbprint] <String> [[-StoreName] <String>] [[-StoreLocation] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Use this function to ensure if a certificate is already imported into a given store.

## EXAMPLES

### BEISPIEL 1
```
Test-CSPfxCertificate -Thumbprint '12345678' -StoreName 'My' -StoreLocation 'CurrentUser'
```

## PARAMETERS

### -Thumbprint
Provide one or more thumbprints.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -StoreName
Select the store name in which you want to search the certificates.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: My
Accept pipeline input: False
Accept wildcard characters: False
```

### -StoreLocation
Select between the both available locations CurrentUser odr LocalMachine.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: CurrentUser
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [None]
## OUTPUTS

### [bool]
## NOTES
File Name   : Test-CSPfxCertificate.ps1
Author      : Marco Blessing - marco.blessing@googlemail.com
Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

