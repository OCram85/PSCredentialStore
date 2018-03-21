---
external help file: PSCredentialStore-help.xml
Module Name: PSCredentialStore
online version: https://github.com/OCram85/PSCredentialStore
schema: 2.0.0
---

# Get-CredentialStoreItem

## SYNOPSIS
Returns the Credential from a given remote host item.

## SYNTAX

### Private (Default)
```
Get-CredentialStoreItem -RemoteHost <String> [-Identifier <String>] [<CommonParameters>]
```

### Shared
```
Get-CredentialStoreItem [-Path <String>] -RemoteHost <String> [-Identifier <String>] [-Shared]
 [<CommonParameters>]
```

## DESCRIPTION
Return the credential as PSCredential object.

## EXAMPLES

### EXAMPLE 1
```
$myCreds = Get-CredentialStoreItem -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local"
```

## PARAMETERS

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
Define a custom path to a shared CredentialStore.

```yaml
Type: String
Parameter Sets: Shared
Aliases:

Required: False
Position: Named
Default value: "{0}\PSCredentialStore\CredentialStore.json" -f $env:ProgramData
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoteHost
Specify the host, for which you would like to change the credentials.

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

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [None]

## OUTPUTS

### [System.Management.Automation.PSCredential]

## NOTES
\`\`\`
File Name   : Get-CredentialStoreItem.ps1
Author      : Marco Blessing - marco.blessing@googlemail.com
Requires    :
\`\`\`

## RELATED LINKS

[https://github.com/OCram85/PSCredentialStore](https://github.com/OCram85/PSCredentialStore)

