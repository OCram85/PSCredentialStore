# Set-CredentialStoreItem

## SYNOPSIS
Changes the credentials for the given remote host in the store.

## SYNTAX

### Private (Default)
```
Set-CredentialStoreItem -RemoteHost <String> [-Identifier <String>] [-Credential <PSCredential>]
 [<CommonParameters>]
```

### Shared
```
Set-CredentialStoreItem -RemoteHost <String> [-Identifier <String>] [-Credential <PSCredential>] [-Shared]
 [-Path <String>] [<CommonParameters>]
```

## DESCRIPTION
Use this function to update your already stored RemoteHost items.

## EXAMPLES

### BEISPIEL 1
```
Set-CredentialStoreItem -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local"
```

### BEISPIEL 2
```
Set-CredentialStoreItem -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local" -Identifier svc
```

## PARAMETERS

### -Credential
Provided the new credentials you want to update inside the RemoteHost item.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Identifier
Defaults to "".
Specify a string, which separates two CredentialStoreItems for the
same hostname.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Define the store in which your given host entry already exists.

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

### -RemoteHost
Specify the host you for which you would like to change the credentials.

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

### [None]
## OUTPUTS

### [None]
## NOTES
- File Name   : Set-CredentialStoreItem.ps1
- Author      : Marco Blessing - marco.blessing@googlemail.com
- Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

