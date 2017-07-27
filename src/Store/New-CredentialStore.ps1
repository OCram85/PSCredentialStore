function New-CredentialStore {
    <#
    .SYNOPSIS
        Creates a new credential store File

    .DESCRIPTION
        You need to run this script first to create a new credential store before you try to
        save new credentials with New-CredentialStoreItem.

    .PARAMETER Path
        Define a location for the new shared CredentialStore. The default store will be created in
        $Env:ProgramData\PSCredentialStore dir.

    .PARAMETER Shared
        Creates a CredentialStore in the Shared mode. This enables you to read the CredentialStore Items on
        different systems or profiles. In addition you can optionally provide a custom path wit the -Path parameter.

    .PARAMETER Force
        Use this switch to reset an existing store. The complete content will be wiped.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        New-CredentialStore
        # Creates a new private CredentialStore

    .EXAMPLE
        New-CredentialStore -Force
        # Resets an existing private CredentialStore

    .EXAMPLE
        New-CredentialStore -Shared
        # Creates a new shead CredentialStore

    .EXAMPLE
        New-CredentialStore -Shared -Path "C:\TMP\CredentialStore.json"
        # Creates a new shared CredentialStore in the given location.

    .NOTES
        File Name   : New-CredentialStore.ps1
        Author      : Marco Blessing - marco.blessing@googlemail.com
        Requires    :

    .LINK
        https://github.com/OCram85/PSCredentialStore
    #>

    [CmdletBinding(DefaultParameterSetName = "Private")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [switch]$Shared,

        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [ValidateNotNullOrEmpty()]
        [string]$Path = "{0}\PSCredentialStore\CredentialStore.json" -f $env:ProgramData,

        [Parameter(Mandatory = $false, ParameterSetName = "Private")]
        [Parameter(Mandatory = $false, ParameterSetName = "Shared")]
        [switch]$Force
    )

    # Lets get the current Date in a human readable format.
    $CurrentDate = Get-Date -UFormat "%Y-%m-%d %H:%M:%S"

    # Set latest Credential Store version
    Set-Variable -Name "CSVersion" -Value "1.2.0" -Option Constant

    # Set the CredentialStore path for private mode.
    Write-Debug ("ParameterSetName: {0}" -f $PSCmdlet.ParameterSetName)
    if ($PSCmdlet.ParameterSetName -eq "Private") {
        $Path = "{0}\CredentialStore.json" -f $Env:APPDATA
    }

    # Test if in the given store already a CredentialStore exists.
    Write-Verbose "Test if there is already a credential store."
    if ((Test-CredentialStore -Path $Path) -and ($Force -ne $true)) {
        $MessageParam = @{
            Message = "The given file already exists. Use the 'Force' switch to override the existing store."
            ErrorAction = "Stop"
        }
        Write-Error @MessageParam
    }
    # We need to use the IDictionary to keep the property sorting in the object.
    $ObjProperties = [ordered]@{
        Version = $CSVersion
        Creation = $CurrentDate
    }
    if ($PSCmdlet.ParameterSetName -eq "Shared") {
        $ObjProperties.Type = "Shared"
        # Check if a ChallengeFile already exists. We don't want to overide it.
        # Otherwise previous created CredentialStores couln't be decrypted anymore.
        if (-not (Test-ChallengeFile)) {
            Set-ChallengeFile
        }
    }
    else {
        $ObjProperties.Type = "Private"
    }
    # Create a new object for easy conversion into a json file
    $CredentialStoreObj = New-Object -TypeName psobject -Property $ObjProperties
    try {
        ConvertTo-Json -InputObject $CredentialStoreObj | Out-File -FilePath $Path
    }
    catch [System.Exception] {
        $_.Exception | Format-List -Force | Out-String | Write-Error -ErrorAction Stop
    }
}
