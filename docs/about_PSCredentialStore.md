# PSCredentialStore
## about_PSCredentialStore


# SHORT DESCRIPTION
PSCredentialStore enables managing multiple PSCredential objects.


# LONG DESCRIPTION
The PSCredentialStore is a simple credential manager for `PSCredential` objects. It stores PSCredentials in a simple json
file. You can choose between a private and shared credential store. The private one exists in your profile and can
ony accessed by your account on the same machine. The shared store enables you to use different credentials for your
scripts without exposing them as plain text.

PSCredentialStore was developed to simplify the delegation of complex powershell scripts. In this case you often
need to store credentials for non interactive usage like in scheduled tasks.

Starting with version `1.0.0` PSCredential uses Pfx certificates fo encryption. You can use Pfx certificate files
or certificates stored in the certificate store.

For more details read the [about_PSCredentialStore](/docs/about_PSCredentialStore.md) page on github or via CLI with
`Get-Help about_PSCredentialStore`.

## Requirements

- PowerShell >= `5.1`
- .NET Framework >= `4.6` or .NET Core >= `1.0`

## Installation

## PowerShellGallery.com (Recommended Way)

* Make sure you use PowerShell 5.1 or higher with `$PSVersionTable`.
* Use the builtin PackageManagement and install with: `Install-Module PSCredentialStore`
* Done. Start exploring the Module with `Import-Module PSCredentialStore ; Get-Command -Module PSCredentialStore`

## Manual Way

* Take a look at the [Latest Release](https://github.com/OCram85/PSCredentialStore/releases/latest) page.
* Download the `PSCredentialStore.zip`.
* Unpack the Zip and put it in your Powershell Module path.
  * Don't forget to change the NTFS permission flag in the context menu.
* Start with `Import-Module PSCredentialStore`

**1.** First we need a blank credential store. You can decide between a *private* or *shared* store. The private
Credential Store can only be accessed with your profile on the machine you created it.

Starting with version `1.0.0` you can decide the storage type of your fresh created certificate. As default
PSCredentialStore creates a new pfx certificate file beside the credential store itself. Optionally you can provide
the parameter `-UseCertStore`. This imports the new certificate in the user or machine certificate store as well.

```powershell
# Private credential store
New-CredentialStore

# Private credential store with certificate store usage
New-CredentialStore -UseCertStore

# Shared credential rtore
New-CredentialStore -Shared

#Shared credential store in custom Location
New-CredentialStore -Shared -Path 'C:\CredentialStore.json'
```


**2.** Now you can manage your CredentialStoreItems:
```powershell
# This will prompt for credentials and stores it in a private store
New-CredentialStoreItem -RemoteHost 'dc01.myside.local' -Identifier 'AD'

# You can now use it in other scripts like this:
$DCCreds = Get-CredentialStoreItem -RemoteHost 'dc01.myside.local' -Identifier 'AD'
Invoke-Command -ComputerName 'dc01.myside.local' -Credential $DCCreds -ScripBlock {Get-Process}
```

The CredentialStore contains also a simple function to establish a connection with several systems or protocols.
If you have already installed the underlying framework your can connect to:

* **CiscoUcs** - Establish a connection to a Cisco UCS fabric interconnect.
  * Required Modules: [`Cisco.UCS.Core`, `Cisco.UCSManager`](https://software.cisco.com/download/release.html?i=!y&mdfid=286305108&softwareid=284574017&release=2.1.1)
* **FTP** - Establish a connection to a FTP host.
  * Required Modules: [`WinSCP`](https://www.powershellgallery.com/packages/WinSCP)
* **NetAppFAS** - Establish a connection to a NetApp Clustered ONTAP filer.
  * Required Modules: [`DataONTAP`](http://mysupport.netapp.com/tools/info/ECMLP2310788I.html?productID=61926)
* **VMware** - Establish a connection to a VMware vCenter or ESXi host.
  * Required Modules: [`VMware.VimAutomation.Core`](https://www.powershellgallery.com/packages/VMware.PowerCLI)
* **CisServer** - Establish a connection to the CisServer Service on vCenter Host.
  * Required Modules: [`VMware.VimAutomation.Cis.Core`](https://www.powershellgallery.com/packages/VMware.PowerCLI))
* **ExchangeHTTP** - Establish a remote connection with an Exchange endpoint via http.
  * Requires PowerShell remoting
* **ExchangeHTTPS** - Establish a remote connection with an Exchange endpoint via https.
  * Requires PowerShell remoting
* **SCP** - Establish a SCP connection.
  * Required Modules: [`WinSCP`](https://www.powershellgallery.com/packages/WinSCP)
# EXAMPLES

```powershell
Connect-To -RemoteHost "ucs.myside.local" -Type CiscoUcs
Connect-To -RemoteHost "ftp.myside.local" -Type FTP
Connect-To -RemoteHost "fas.myside.local" -Type NetAppFAS
Connect-To -RemoteHost "esx01.myside.local" -Type VMware
Connect-To -RemoteHost "vcr.myside.local" -Type CisServer
```
# NOTE


# TROUBLESHOOTING NOTE


# SEE ALSO


# KEYWORDS

- Credential
- Store
