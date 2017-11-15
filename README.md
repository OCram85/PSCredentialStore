[![AppVeyor branch](https://img.shields.io/appveyor/ci/OCram85/PSCredentialStore/master.svg?style=plastic "Master Banch Build Status")](https://ci.appveyor.com/project/OCram85/pscredentialstore/branch/master)
[![AppVeyor tests branch](https://img.shields.io/appveyor/tests/OCram85/PSCredentialStore/master.svg?style=plastic "Pester Tests Results")](https://ci.appveyor.com/project/OCram85/pscredentialstore/branch/master/tests)
[![Coveralls github](https://img.shields.io/coveralls/github/OCram85/PSCredentialStore.svg?style=plastic "Coveralls.io Coverage Report")](https://coveralls.io/github/OCram85/PSCredentialStorebranch=master)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PSCredentialStore.svg?style=plastic "PowershellGallery Published Version")](https://www.powershellgallery.com/packages/PSCredentialStore)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSCredentialStore.svg?style=plastic "PowershellGallery Downloads")](https://www.powershellgallery.com/packages/PSCredentialStore)

![forthebadge](http://forthebadge.com/images/badges/built-with-love.svg)
![forthebadge](http://forthebadge.com/images/badges/for-you.svg)

General
=======

The PSCredentialStore is a simple credential manager for PSCredentials. It stores PSCredentials in a simple json
file. You can choose between a private and shared credential store. The private one exists in your profile and can
ony accessed by your account on the same machine. The shared store enables you to use different credentials for your
scripts without exposing them as plain text.

**The shared store isn't 100% secure and I don't recommend using it in production!**

PSCredentialStore was developed to simplify the delegation of complex powershell scripts. In this case you often
need to store credentials for non interactive usage like in scheduled tasks.

For more details read the [about_PSCredentialStore](/src/en-US/about_PSCredential.help.txt) page.

Installation
============

PowerShellGallery.com (Recommended Way)
---------------------------------------

* Make sure you use PowerShell 4.0 or higher with `$PSVersionTable`.
* Use the builtin PackageManagement and install with: `Install-Module PSCredentialStore`
* Done. Start exploring the Module with `Import-Module PSCredentialStore ; Get-Command -Module PSCredentialStore`

Manual Way
----------

* Take a look at the [Latest Release](https://github.com/OCram85/PSCredentialStore/releases/latest) page.
* Download the `PSCredentialStore.zip`.
* Unpack the zip file and put it in your Powershell module path.
  * Don't forget to change the NTFS permission flag in the context menu.
* Start with `Import-Module PSCredentialStore`

Quick Start
-----------

**1.** First we need a blank credential store. You can decide between a *private* or *shared* store. The private
Credential Store can only be accessed with your profile on the machine you created it.
```powershell
# Private credential store
New-CredentialStore

# Shared credential rtore
New-CredentialStore -Shared

#Shared credential store in custom Location
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

Here are some basic examples:

```powershell
Connect-To -RemoteHost "ucs.myside.local" -Type CiscoUcs
Connect-To -RemoteHost "ftp.myside.local" -Type FTP
Connect-To -RemoteHost "fas.myside.local" -Type NetAppFAS
Connect-To -RemoteHost "esx01.myside.local" -Type VMware
Connect-To -RemoteHost "vcr.myside.local" -Type CisServer
```
