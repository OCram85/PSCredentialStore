# Test-CSCertificate

## SYNOPSIS
Tests if the linked certificate is store ein the specified cert stores.

## SYNTAX

```
Test-CSCertificate [-Type] <String> [<CommonParameters>]
```

## DESCRIPTION
Test-CSCertificate should be an easy high level test for the linked certificate.

## EXAMPLES

### BEISPIEL 1
```
Test-CSCertificate -Type 'Shared'
```

## PARAMETERS

### -Type
Select between 'Private' or 'Shared'.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [None]
## OUTPUTS

### [bool]
## NOTES
- File Name   : Test-CSCertificate.ps1
- Author      : Marco Blessing - marco.blessing@googlemail.com
- Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

