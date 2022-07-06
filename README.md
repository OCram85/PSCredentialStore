# Give Up GitHub

This project has given up GitHub.  ([See Software Freedom Conservancy's *Give Up  GitHub* site for details](https://GiveUpGitHub.org).)

You can now find this project at [https://gitea.ocram85.com/OCram85/PSCredentialStore](https://gitea.ocram85.com/OCram85/PSCredentialStore) instead.

Any use of this project's code by GitHub Copilot, past or present, is done without our permission.  We do not consent to GitHub's use of this project's code in Copilot.

Join us; you can [give up GitHub](https://GiveUpGitHub.org) too!

![Logo of the GiveUpGitHub campaign](https://sfconservancy.org/img/GiveUpGitHub.png)


![forthebadge](http://forthebadge.com/images/badges/built-with-love.svg)
![forthebadge](http://forthebadge.com/images/badges/for-you.svg)

![social-logo](/assets/social-logo.png)

:key: General
=======

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

You can find the [reference](/docs/PSCredentialStore.md) in the /docs/ path as well.

:vulcan_salute: Requirements
============

- PowerShell >= `5.1`
- .NET Framework >= `4.6` or .NET Core >= `1.0`

:bomb: About Security
============

>This section explains some security topics and the the design decisions we made to balance the usage and security needs.

To be able to delegate `PSCredentials` objects we can't exclusively rely on the `SecureString` cmdlets. You can't
decrypt and reuse such credentials from a different user account or even machine. This is caused by automatically
generated encryption key which, is used create a `Secure String` based encrypted string.

In order to delegate a password, while still using the underlying security framework, we have to provide a custom
encryption key. This leads to the fact, that everyone who has access to the key could encrypt or decrypt your data.

So we decided to use the public and private keys from valid certificates as part of the custom encryption keys to encrypt your data.

This means clearly: Everyone who has access to the `CredentialStore` needs also access to the certificate file to work with it.

Keep in mind you need to secure the access with your NTFS file permissions to avoid unwanted usage. Another option is
to import the certificate into your certification vaults of you operating system. In this case you can grand the
permission to the certificates itself.

Here is s brief hierarchy description of the certificate location: *(First match wins)*

| CredentialStore Type | Certificate Location   |
| -------------------- | ---------------------- |
| Private              | `CurrentUser`\\`My`    |
| Shared (Windows)     | `CurrentUser`\\`My`    |
|                      | `LocalMachine`\\`Root` |
| Shared (Linux)       | `LocalMachine`\\`My`   |
|                      | `LocalMachine`\\`Root` |



:hammer_and_wrench: Installation
============

:artificial_satellite: PowerShellGallery.com (Recommended Way)
---------------------------------------

* Make sure you use PowerShell 5.1 or higher with `$PSVersionTable`.
* Use the builtin PackageManagement and install with: `Import-Module PowerShellGet; Install-Module 'PSCredentialStore' -Repository 'PSGallery'`
  * Additionally use the `-AllowPrerelease` switch until we publish the final release!
* Done. Start exploring the Module with `Import-Module PSCredentialStore ; Get-Command -Module PSCredentialStore`

:building_construction: Manual Way
----------

* Take a look at the [Latest Release](https://github.com/OCram85/PSCredentialStore/releases/latest) page.
* Download the `PSCredentialStore.zip`.
* Unpack the zip file and put it in your Powershell module path.
  * Don't forget to change the NTFS permission flag in the context menu.
* Start with `Import-Module PSCredentialStore`

:sparkles: Quick Start
-----------

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

# Shared credential store
New-CredentialStore -Shared

#Shared credential store in custom location
New-CredentialStore -Shared -Path 'C:\CredentialStore.json'
```

**2.** Now you can manage your credential store items:
```powershell
# This will prompt for credentials and stores it in a private store
New-CredentialStoreItem -RemoteHost 'dc01.myside.local' -Identifier 'AD'

# You can now use it in other scripts like this:
$DCCreds = Get-CredentialStoreItem -RemoteHost 'dc01.myside.local' -Identifier 'AD'
Invoke-Command -ComputerName 'dc01.myside.local' -Credential $DCCreds -ScripBlock {Get-Process}
```

The credential store contains also a simple function to establish a connection with several systems or protocols.
If you have already installed the underlying framework / modules, you can connect these endpoints:

* **CiscoUcs** - Establish a connection to a Cisco UCS fabric interconnect.
  * Required Modules: [`Cisco.UCS.Core`, `Cisco.UCSManager`](https://software.cisco.com/download/release.html?i=!y&mdfid=286305108&softwareid=284574017&release=2.1.1)
* **FTP** - Establish a connection to a FTP host.
  * Required Modules: [`WinSCP`](https://www.powershellgallery.com/packages/WinSCP)
* **NetAppFAS** - Establish a connection to a NetApp Clustered ONTAP filer.
  * Required Modules: [`DataONTAP`](http://mysupport.netapp.com/tools/info/ECMLP2310788I.html?productID=61926)
* **VMware** - Establish a connection to a VMware vCenter or ESXi host.
  * Required Modules: [`VMware.VimAutomation.Core`](https://www.powershellgallery.com/packages/VMware.PowerCLI)
* **CisServer** - Establish a connection to the CisServer Service on vCenter Host.
  * Required Modules: [`VMware.VimAutomation.Cis.Core`](https://www.powershellgallery.com/packages/VMware.PowerCLI)
* **ExchangeHTTP** - Establish a remote connection with an Exchange endpoint via http.
  * Requires PowerShell remoting
* **ExchangeHTTPS** - Establish a remote connection with an Exchange endpoint via https.
  * Requires PowerShell remoting
* **SCP** - Establish a SCP connection.
  * Required Modules: [`WinSCP`](https://www.powershellgallery.com/packages/WinSCP)

Here are some basic examples:

```powershell
Connect-To -RemoteHost "ucs.myside.local" -Type CiscoUcs
Connect-To -RemoteHost "ftp.myside.local" -Type FTP
Connect-To -RemoteHost "fas.myside.local" -Type NetAppFAS
Connect-To -RemoteHost "esx01.myside.local" -Type VMware
Connect-To -RemoteHost "vcr.myside.local" -Type CisServer
Connect-To -RemoteHost "exchange1.myside.local" -Type ExchangeHTTP
Connect-To -RemoteHost "exchange1.myside.local" -Type ExchangeHTTPS
Connect-To -RemoteHost "ubuntu.myside.local" -Type SCP
```

:pushpin: Credits
-------

A huge thanks to all the people who helped with their projects and indirect contributions which made this possible!

- This module is inspired by the awesome work of Dave Wyatt ([@dlwyatt](https://github.com/dlwyatt)) with articles like these:
  - https://powershell.org/2013/11/24/saving-passwords-and-preventing-other-processes-from-decrypting-them/
  - https://powershell.org/2014/02/01/revisited-powershell-and-encryption/
- The awesome people from [LibreSSL](http://www.libressl.org/) which publishes the [portable openssl/libressl binaries](https://github.com/libressl-portable/portable)!
