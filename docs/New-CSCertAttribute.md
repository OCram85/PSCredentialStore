---
external help file: PSCredentialStore-help.xml
Module Name: PSCredentialStore
online version: https://github.com/OCram85/PSCredentialStore
schema: 2.0.0
---

# New-CSCertAttribute

## SYNOPSIS
Creates required data for a certificate signing request.

## SYNTAX

```
New-CSCertAttribute [-Country] <String> [-State] <String> [-City] <String> [-Organization] <String>
 [-OrganizationalUnitName] <String> [-CommonName] <String> [[-Days] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Defines the certificate related properties for an upcoming New-PfxCertificate execution.

## EXAMPLES

### BEISPIEL 1
```
New-CSCertAttribute -Country 'DE' -State 'BW' -City 'Karlsruhe' -Organization 'AwesomeIT' -OrganizationalUnitName '' -CommonName 'MyPrivateCert'
```

## PARAMETERS

### -Country
County code like EN, DE, IT, FR...

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

### -State
Certificate state value.

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

### -City
Certificate city value.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Organization
Certificate organization value.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OrganizationalUnitName
Certificate OrganizationalUnitName value.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommonName
The certificate common name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Days
{{ Fill Days Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: 365
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [None]
## OUTPUTS

### ['PSCredentialStore.Certificate.CSRDetails']
## NOTES
- File Name   : New-CSCertAttribute.ps1
- Author      : Marco Blessing - marco.blessing@googlemail.com
- Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

