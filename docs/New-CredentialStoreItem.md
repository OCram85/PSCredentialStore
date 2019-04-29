# New-CredentialStoreItem

## SYNOPSIS
Adds a credential store item containing host, user and password to the given store.

## SYNTAX

### Private (Default)
```
New-CredentialStoreItem -RemoteHost <String> [-Identifier <String>] [-Credential <PSCredential>]
 [<CommonParameters>]
```

### Shared
```
New-CredentialStoreItem -RemoteHost <String> [-Identifier <String>] [-Credential <PSCredential>] [-Shared]
 [-Path <String>] [<CommonParameters>]
```

## DESCRIPTION
The credentials are stored without any relations to it's further use.
If you need to change an existing
item please use Set-CredentialStoreItem.
You need to decide afterwards, whether to use the credential for
a VIConnection, NetApp FAS or UCS Fabric Interconnect.

## EXAMPLES

### BEISPIEL 1
```
New-CredentialStoreItem -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local"
```

## PARAMETERS

### -Credential
You can provide credentials optionally as pre existing pscredential object.

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
Provide a custom identifier to the given remote host key.
This enables you to store multiple credentials
for a single remote host entry.
For example ad/sys1, ftp/sys1, mssql/sys1

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
Define the store in which you would like to add a new item.

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
The identifier or rather name for the given credentials.

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
Define the CredentialStore where you want to add the new item.
Default is always personal but can be
changed to shared, or even shared with custom path.

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
- File Name   : New-CredentialStoreItem.ps1
- Author      : Marco Blessing - marco.blessing@googlemail.com
- Requires    :

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

