# Import-CSCertificate

## SYNOPSIS
Imports a linked certificate to the valid store location.

## SYNTAX

```
Import-CSCertificate [-Type] <String> [-Path] <FileInfo> [<CommonParameters>]
```

## DESCRIPTION
Import-CSCertificate takes a pfx certificate file and imports it to the supposed certificate store for
private and shared credential stores.

## EXAMPLES

### BEISPIEL 1
```
.\Remove-Some-Script.ps1 -One content
```

## PARAMETERS

### -Path
Provide a valid path to pfx certificate file.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Select between the a private and shared credential store.

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

### Describe the script input parameters (if any), otherwise it may also list the word "[None]".
## OUTPUTS

### Describe the script output parameters (if any), otherwise it may also list the word "[None]".
## NOTES
- File Name   : Import-CSCertificate.ps1
- Author      : Marco Blessing - marco.blessing@googlemail.com
- Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

