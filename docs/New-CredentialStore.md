---
external help file: PSCredentialStore-help.xml
Module Name: PSCredentialStore
online version: https://github.com/OCram85/PSCredentialStore
schema: 2.0.0
---

# Import-CSPfxCertificate

## SYNOPSIS
Adds a given pfx certificate file to current user's personal certificate store.

## SYNTAX

```
Import-CSPfxCertificate [-Path] <String> [[-StoreName] <String>] [[-StoreLocation] <String>]
 [[-OpenFlags] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function is used to import existing pfx certificate files.
The Import-PFXCertificate cmdlet from the
PKI module imports the certificate into a deprecated store.
Thus you can't read the private key afterwards or
using it for decrypting data.

## EXAMPLES

### BEISPIEL 1
```
Import-CSPfxCertificate -Path (Join-Path -Path $Env:APPDATA -ChildPath '/PSCredentialStore.pfx')
```

## PARAMETERS

### -Path
Path to an existing *.pfx certificate file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StoreName
Additionally you change change the store where you want the certificate into.

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
{{ Fill StoreLocation Description }}

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

### -OpenFlags
{{ Fill OpenFlags Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: ReadWrite
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
File Name   : Import-CSPfxCertificate.ps1
Author      : Marco Blessing - marco.blessing@googlemail.com
Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

