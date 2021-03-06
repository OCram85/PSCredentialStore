# Test-CredentialStore

## SYNOPSIS
Returns the credential store state.

## SYNTAX

### Private (Default)
```
Test-CredentialStore [<CommonParameters>]
```

### Shared
```
Test-CredentialStore [-Path <String>] [-Shared] [<CommonParameters>]
```

## DESCRIPTION
Use this script to test your credential store.
For now it only checks if
the file exists.

## EXAMPLES

### BEISPIEL 1
```
Test-CredentialStore -eq $true
```

## PARAMETERS

### -Path
Define a custom path to a shared CredentialStore.

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

### -Shared
Switch to shared mode with this param.
This enforces the command to work with a shared CredentialStore which
can be decrypted across systems.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
- File Name   : Test-CredentialStore.ps1
- Author      : Marco Blessing - marco.blessing@googlemail.com
- Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

