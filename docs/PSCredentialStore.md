---
Module Name: PSCredentialStore
Module Guid: 6800e192-9df8-4e30-b253-eb2c799bbe84 6800e192-9df8-4e30-b253-eb2c799bbe84
Download Help Link: {{ Update Download Link }}
Help Version: {{ Please enter version of help manually (X.X.X.X) format }}
Locale: en-US
---

# PSCredentialStore Module
## Description
[about_PSCredentialStore](about_PSCredentialStore.md)

## PSCredentialStore Cmdlets
### [Connect-To](Connect-To.md)
Connects to the given host using the stored CredentialStoreItem.

### [Disconnect-From](Disconnect-From.md)
Terminates a session established with Connect-To using a CredentialStoreItem.

### [Get-CredentialStore](Get-CredentialStore.md)
Reads the complete content of the credential store and returns it as a new object.

### [Get-CredentialStoreItem](Get-CredentialStoreItem.md)
Returns the Credential from a given remote host item.

### [Get-CSCertificate](Get-CSCertificate.md)
Returns the current used valid PfX certificate.

### [Get-CSPfxCertificate](Get-CSPfxCertificate.md)
Returns the certificate object given by thumbprint.

### [Import-CSCertificate](Import-CSCertificate.md)
Imports a linked certificate to the valid store location.

### [Import-CSPfxCertificate](Import-CSPfxCertificate.md)
Adds a given pfx certificate file to current user's personal certificate store.

### [Import-CSPfxCertificate](Import-CSPfxCertificate.md)
Adds a given pfx certificate file to current user's personal certificate store.

### [New-CredentialStoreItem](New-CredentialStoreItem.md)
Adds a credential store item containing host, user and password to the given store.

### [New-CSCertAttribute](New-CSCertAttribute.md)
Creates required data for a certificate signing request.

### [New-CSCertificate](New-CSCertificate.md)
Creates a new PFX certificate for the CredentialStore encryption.

### [Remove-CredentialStoreItem](Remove-CredentialStoreItem.md)
Remove the given credentials from the credential store.

### [Set-CredentialStoreItem](Set-CredentialStoreItem.md)
Changes the credentials for the given remote host in the store.

### [Test-CredentialStore](Test-CredentialStore.md)
Returns the credential store state.

### [Test-CredentialStoreItem](Test-CredentialStoreItem.md)
Checks if the given RemoteHost identifier combination exists in the credential store.

### [Test-CSCertificate](Test-CSCertificate.md)
Tests if the linked certificate is store ein the specified cert stores.

### [Test-CSConnection](Test-CSConnection.md)
Returns the connection state of a given type to the remote host.

### [Test-CSPfxCertificate](Test-CSPfxCertificate.md)
Tests if the given certificate exists in a store.

### [Use-CSCertificate](Use-CSCertificate.md)
Links an existing PFX Certificate to a CredentialStore.

