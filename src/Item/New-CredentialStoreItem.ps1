function New-CredentialStoreItem {
    <#
    .SYNOPSIS
        Adds a credential store item containing host, user and password to the given store.

    .DESCRIPTION
        The credentials are stored without any relations to it's further use. If you need to change an existing
        item please use Set-CredentialStoreItem. You need to decide afterwards, whether to use the credential for
        a VIConnection, NetApp FAS or UCS Fabric Interconnect.

    .PARAMETER Path
        Define the store in which you would like to add a new item.

    .PARAMETER RemoteHost
        The identifier or rather name for the given credentials.

    .PARAMETER Identifier
        Provide a custom identifier to the given remote host key. This enables you to store multiple credentials
        for a single remote host entry. For example ad/sys1, ftp/sys1, mssql/sys1

    .PARAMETER Credential
        You can provide credentials optionally as pre existing pscredential object.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        New-CredentialStoreItem -Path "C:\TMP\mystore.json" -RemoteHost "esx01.myside.local"

    .NOTES
        File Name   : New-CredentialStoreItem.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>

    [CmdletBinding(DefaultParameterSetName = "Private")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [string]$Path = "{0}\PSCredentialStore\CredentialStore.json" -f $env:ProgramData,

        [Parameter(Mandatory = $true, ParameterSetName = "Shared")]
        [Parameter(Mandatory = $true, ParameterSetName = "Private")]
        [ValidateNotNullOrEmpty()]
        [string]$RemoteHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [Parameter(Mandatory = $false, ParameterSetName = "Private")]
        [ValidateNotNullOrEmpty()]
        [string]$Identifier,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential,

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [switch]$Shared
    )

    # First set a constand path for private CredentialStore mode.
    if ($PSCmdlet.ParameterSetName -eq "Private") {
        $Path = "{0}\CredentialStore.json" -f $env:APPDATA
    }

    # Lets do a quick test on the given CredentialStore.
    if (-not(Test-CredentialStore -Path $Path)) {
        $MessageParams = @{
            Message = "Could not add anything into the given CredentailStore."
            ErrorAction = "Stop"
        }
        Write-Error @MessageParams
    }

    # Read the file content based on the given ParameterSetName
    $CSContent = Get-CredentialStore -Path $Path

    $CurrentDate = Get-Date -UFormat "%Y-%m-%d %H:%M:%S"

    if ($Identifier -ne "") {
        $CredentialName = $RemoteHost = "{0}/{1}" -f $Identifier, $RemoteHost
    }
    else {
        $CredentialName = $RemoteHost
    }

    if (-not($Credential)) {
        $Credential = Get-Credential -Message $CredentialName
    }

    if ($Credential.UserName) {
        if ($CSContent.Type -eq "Shared") {
            $Key = Get-ChallengeFile
            $encypted = ConvertFrom-SecureString -SecureString $Credential.Password -Key $Key
        }
        else {
            $encypted = ConvertFrom-SecureString -SecureString $Credential.Password
        }
        if (Get-Member -InputObject $CSContent -Name $CredentialName -Membertype Properties) {
            $MessageParams = @{
                Message = "The given host already exists. Nothing to do here."
            }
            Write-Warning @MessageParams
        }
        else {
            $CredentialHash = [ordered]@{
                User = $Credential.UserName
                Password = $encypted
                Creation = $CurrentDate
            }
            Add-Member -InputObject $CSContent -Name $CredentialName -MemberType NoteProperty -Value $CredentialHash
            try {
                ConvertTo-Json -InputObject $CSContent | Out-File -FilePath $Path
            }
            catch [System.Exception] {
                $MessageParams = @{
                    Message = "Couldn't add item into credential store!"
                    ErrorAction = "Stop"
                }
                Write-Error @MessageParams
            }
        }
    }
    else {
        $MessageParams = @{
            Message = "Please Provide at least a valid user!"
            ErrorAction = "Stop"
        }
        Write-Error @MessageParams
    }
}
