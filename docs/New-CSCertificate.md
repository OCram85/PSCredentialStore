# New-CSCertificate

## SYNOPSIS
Creates a new PFX certificate for the CredentialStore encryption.

## SYNTAX

```
New-CSCertificate [-CRTAttribute] <Object> [[-KeyName] <String>] [[-CertName] <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Use this function to create a custom self signed certificate used by the PSCredentialStore module.

## EXAMPLES

### BEISPIEL 1
```
New-CSCertificate -CRTAttribute $CRTAttribute -KeyName './myprivate.key' -CertName './mycert.pfx'
```

## PARAMETERS

### -CertName
Provide a custom full path and name for the PFX certificate file.
The file extension has to be \`*.pfx\`

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: ./certificate.pfx
Accept pipeline input: False
Accept wildcard characters: False
```

### -CRTAttribute
Provide certificate related attributes provided by function New-CRTAttribute.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -KeyName
Provide a custom full path and name for the private key.
The file extension has to be \`*.key\`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: ./private.key
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [PSCredentialStore.Certificate.Attribute]
## OUTPUTS

### [None]
## NOTES
- File Name   : New-CSCertificate.ps1
- Author      : Marco Blessing - marco.blessing@googlemail.com
- Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

