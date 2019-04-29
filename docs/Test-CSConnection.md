# Test-CSConnection

## SYNOPSIS
Returns the connection state of a given type to the remote host.

## SYNTAX

```
Test-CSConnection [-RemoteHost] <String> [-Type] <String> [<CommonParameters>]
```

## DESCRIPTION
Use this script to check a connection which was established with the \`Connect-To\` cmdlet.

## EXAMPLES

### BEISPIEL 1
```
Test-CMConnection -RemoteHost "vcr01.internal.net" -Type VMware
```

## PARAMETERS

### -RemoteHost
Define the remote host you would like to check.

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

### -Type
Define the connection type you would like to check.
See the \`Connect-To\` documentation
for valid type values.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [None]
## OUTPUTS

### [bool]
## NOTES
- File Name   : Test-CSConnection.ps1
- Author      : Marco Blessing - marco.blessing@googlemail.com
- Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

