| AppVeyor Overall | AppVeyor Master | AppVeyor Dev | Coveralls.io  | Download |
| :--------------: | :-------------: | :----------: | :-----------: | :--------:|
| [![Build status](https://ci.appveyor.com/api/projects/status/b4t8x88xai3ee7gk?svg=true)](https://ci.appveyor.com/project/OCram85/PSCredentialStore) | [![Build status](https://ci.appveyor.com/api/projects/status/b4t8x88xai3ee7gk/branch/master?svg=true)](https://ci.appveyor.com/project/OCram85/PSCredentialStore/branch/master) | [![Build status](https://ci.appveyor.com/api/projects/status/b4t8x88xai3ee7gk/branch/dev?svg=true)](https://ci.appveyor.com/project/OCram85/PSCredentialStore/branch/dev) | [![Coverage Status](https://coveralls.io/repos/github/OCram85/PSCredentialStore/badge.svg?branch=master)](https://coveralls.io/github/OCram85/PSCredentialStore?branch=master) | [![Download](https://img.shields.io/badge/powershellgallery-PSCredentialStore-blue.svg)](https://www.powershellgallery.com/packages/PSCredentialStore)

General
=======

The PSCredentialStore is an simple credential manager for PSCredentials. It stores multiple credential object in a
simple json file. Either as private file in your profile or in shared mode in other locations.

PSCredentialStore was developed to simplify the delegation of complex powershell scripts. In this case you often
need to store credentials for non interactive usage like in sheduled tasks.

To get started read the [about_PSCredentialStore](/src/en-US/about_PSCredential.help.txt) page.

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
* Unpack the Zip and put it in your Powershell Module path.
  * Don't forget to change the NTFS permission flag in the context menu.
* Start with `Import-Module PSCredentialStore`

Quick Start
-----

**1.** First we need a blank CredentialStore. You can decide between a *private* or *shared* store. The private
Credential Store can only be accessed with your profile on the machine you created it.
```powershell
# Private Credential Store
New-CredentialStore

# Shared Credential Store
New-CredentialStore -Shared

#Shared CredentialStore in custom Location
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

The CredentialStore contains also a simple function to establish a connection with the given remotehost in different
ways. If you have already installed the underlying framework your can conntect to:
  - CiscoUcs - Establish a connection to a Cisco UCS fabric interconnect.
  - FTP - Establish a connection to a FTP host.
  - NetAppFAS - Establish a connection to a NetApp Clustered ONTAP filer.
  - VMware - Establish a connection to a VMware vCenter or ESXi host.

Here are some basic examples:

```powershell
Connect-To -RemoteHost "ucs.myside.local" -Type CiscoUcs
Connect-To -RemoteHost "ftp.myside.local" -Type FTP
Connect-To -RemoteHost "fas.myside.local" -Type NetAppFAS
Connect-To -RemoteHost "esx01.myside.local" -Type VMware
```
