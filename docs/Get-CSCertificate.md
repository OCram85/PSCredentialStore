# Get-CSCertificate

## SYNOPSIS
Returns the current used valid PfX certificate.

## SYNTAX

```
Get-CSCertificate [-Type] <String> [-Thumbprint] <String> [<CommonParameters>]
```

## DESCRIPTION
Use this function to get the available pfx certificate respecting the config hierarchy.

## EXAMPLES

### BEISPIEL 1
```
Get-CSCertificate -Type 'Shared' -Thumbprint '12334456'
```

## PARAMETERS

### -Thumbprint
Provide the credentials thumbprint for the search.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Select the current credential store type.

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

### [System.Security.Cryptography.X509Certificates.X509Certificate2]
## NOTES
- File Name   : Get-CSCertificate.ps1
- Author      : Marco Blessing - marco.blessing@googlemail.com
- Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

