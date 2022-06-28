function Connect-To {
    <#
    .SYNOPSIS
        Connects to the given host using the stored CredentialStoreItem.

    .DESCRIPTION
        Establish a connection to the selected host using a stored CredentialStoreItem.

    .PARAMETER RemoteHost
        Specify the host, for which you would like to change the credentials.

    .PARAMETER Identifier
        Defaults to "". Specify a string, which separates two CredentialStoreItems for the
        same hostname.

    .PARAMETER Type
        Specify the host type of the target. Currently implemented targets are: Possible connection values are:
        CiscoUcs, FTP, NetAppFAS, VMware, CisServer, ExchangeHTTP, ExchangeHTTPS, SCP.

    .PARAMETER Credentials
        Use this parameter to bypass the stored credentials. Without this parameter Connect-To tries to read the
        needed credentials from the CredentialStore. If you provide this parameter you skip this lookup behavior.
        So you can use it to enable credentials without preparing any user interaction.

    .PARAMETER Path
        Define a custom path to a shared CredentialStore.

    .PARAMETER Shared
        Switch to shared mode with this param. This enforces the command to work with a shared CredentialStore which
        can be decrypted across systems.

    .PARAMETER PassThru
        Returns the value from the underlying connection type function.

    .INPUTS
        [None]

    .OUTPUTS
        [None]

    .EXAMPLE
        Connect-To -RemoteHost "ucs.myside.local" -Type CiscoUcs

    .EXAMPLE
        Connect-To -RemoteHost "ftp.myside.local" -Type FTP

    .EXAMPLE
        Connect-To -RemoteHost "fas.myside.local" -Type NetAppFAS

    .EXAMPLE
        Connect-To -RemoteHost "esx01.myside.local" -Type VMware

    .EXAMPLE
        Connect-To -RemoteHost "vCenter.myside.local" -Type CisServer

    .EXAMPLE
        Connect-To -RemoteHost "exchange01.myside.local" -Type ExchangeHTTP

    .EXAMPLE
        Connect-To -RemoteHost "exchange01.myside.local" -Type ExchangeHTTPS
    #>

    [CmdletBinding(DefaultParameterSetName = 'Private')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Shared')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Private')]
        [string]$RemoteHost,

        [Parameter(Mandatory = $false, ParameterSetName = 'Shared')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Private')]
        [string]$Identifier,

        [Parameter(Mandatory = $true, ParameterSetName = 'Shared')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Private')]
        [ValidateSet(
            'CiscoUcs',
            'FTP',
            'NetAppFAS',
            'VMware',
            'CisServer',
            'ExchangeHTTP',
            'ExchangeHTTPS',
            'SCP'
        )]
        [string]$Type,

        [Parameter(Mandatory = $False, ParameterSetName = 'Shared')]
        [Parameter(Mandatory = $False, ParameterSetName = 'Private')]
        [PSCredential]$Credentials,

        [Parameter(Mandatory = $true, ParameterSetNAme = 'Shared')]
        [switch]$Shared,

        [Parameter(Mandatory = $False, ParameterSetName = 'Shared')]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $False, ParameterSetName = 'Private')]
        [Parameter(Mandatory = $False, ParameterSetName = 'Shared')]
        [switch]$PassThru
    )

    begin {
        # Set the CredentialStore for private, shared or custom mode.
        Write-Debug ("ParameterSetName: {0}" -f $PSCmdlet.ParameterSetName)
        if ($PSCmdlet.ParameterSetName -eq 'Private') {
            $Path = Get-DefaultCredentialStorePath
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'Shared') {
            if (!($PSBoundParameters.ContainsKey('Path'))) {
                $Path = Get-DefaultCredentialStorePath -Shared
            }
        }

        # First check the optional modules
        if (-not (Resolve-Dependency -Name $Type)) {
            Write-Error -Message ("Could not resolve the optional dependencies defined for {0}" -f $Type) -ErrorAction 'Stop'
        }
        switch ($Type) {
            "VMware" {
                # Disable the yellow certificate warning, since we haven't replaced the SSL certs for vCenter/ESXi
                $null = Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Ignore -Confirm:$false

                # Disable connecting through proxy, since vCenter isn't somewhere we need a proxy for.
                $null = Set-PowerCLIConfiguration -Scope Session -ProxyPolicy NoProxy -Confirm:$false
            }
        }
    }

    process {
        if (-not ($Credentials)) {
            # Load the credential from the CredentialStore. If the credential doesn't exist, we need to
            # return 1, so a calling if statement can handle the failure detection.

            # Check if $Identifier has been defined, in which case we need to use different name for
            # the lookup of the CredentialStoreItem.
            try {
                if ($Identifier -ne "") {
                    $RemoteHostIdentifier = "{0}/{1}" -f $Identifier, $RemoteHost
                    $creds = Get-CredentialStoreItem -Shared -RemoteHost $RemoteHostIdentifier -Path $Path
                }
                else {
                    $creds = Get-CredentialStoreItem -Shared -RemoteHost $RemoteHost -Path $Path
                }
            }

            catch {
                $MessageParams = @{
                    Message     = "Unable to look up credential store item for RemoteHost {0}/Identifier {1}!" -f $RemoteHost, $Identifier
                    ErrorAction = 'Stop'
                }
                Write-Error @MessageParams
            }
        }
        else {
            $creds = $Credentials
        }

        if ($creds.UserName -eq "" -or $creds.Password.GetType().Name -ne 'SecureString') {
            $MessageParams = @{
                Message     = "Please provide valid credentials for RemoteHost {0}!" -f $RemoteHost
                ErrorAction = 'Stop'
            }
            Write-Error @MessageParams
        }
        else {
            switch ($Type) {
                "CiscoUcs" {
                    try {
                        $handle = Connect-Ucs -Name $RemoteHost -Credential $creds -ErrorAction Stop
                        $ExecutionContext.SessionState.PSVariable.Set('DefaultUcs', $handle)
                    }

                    catch {
                        $MessageParams = @{
                            Message     = "Unable to connect to {0} using Type {1}." -f $RemoteHost, $Type
                            ErrorAction = 'Stop'
                        }
                        Write-Error @MessageParams
                    }
                }
                "FTP" {
                    # First establish the FTP session
                    $WinSCPConParams = @{
                        Credential = $creds
                        Hostname   = $RemoteHost
                        Protocol   = 'Ftp'
                        FtpMode    = 'Passive'
                    }
                    try {
                        $FTPSessionOption = New-WinSCPSessionOption @WinSCPConParams
                        $Global:WinSCPSession = New-WinSCPSession -SessionOption $FTPSessionOption
                    }
                    catch {
                        throw "Could not connect to {0} using {1} protocol!" -f $RemoteHost, $Type
                    }
                    # Check the Connection State
                    if (!($WinSCPSession.Opened)) {
                        # Check the connection state and find out if the session is still open.
                        $MessageParams = @{
                            Message     = "Connection to {0} using Type {1} was established. But now it seems to be lost!" -f $RemoteHost, $Type
                            ErrorAction = 'Stop'
                        }
                        Write-Error @MessageParams
                    }
                }
                "NetAppFAS" {
                    try {
                        $null = Connect-NcController -Name $RemoteHost -Credential $creds -ErrorAction Stop -HTTPS
                    }

                    catch {
                        # Write a error message to the log.
                        $MessageParams = @{
                            Message     = "Unable to connect to {0} using Type {1}." -f $RemoteHost, $Type
                            ErrorAction = 'Stop'
                        }
                        Write-Error @MessageParams
                    }
                }
                "VMware" {
                    try {
                        Connect-VIServer -Server $RemoteHost -Credential $creds -ErrorAction Stop | Out-Null
                    }

                    catch {
                        # Write a error message to the log.
                        $MessageParams = @{
                            Message     = "Unable to connect to {0} using Type {1}." -f $RemoteHost, $Type
                            ErrorAction = 'Stop'
                        }
                        Write-Error @MessageParams
                    }
                }
                "CisServer" {
                    try {
                        if ($PassThru.IsPresent) {
                            Connect-CisServer -Server $RemoteHost -Credential $creds -ErrorAction Stop
                        }
                        else {
                            Connect-CisServer -Server $RemoteHost -Credential $creds -ErrorAction Stop | Out-Null
                        }

                    }

                    catch {
                        # Write a error message to the log.
                        $MessageParams = @{
                            Message     = "Unable to connect to {0} using Type {1}." -f $RemoteHost, $Type
                            ErrorAction = 'Stop'
                        }
                        Write-Error @MessageParams
                    }
                }
                "ExchangeHTTP" {
                    try {
                        $ConnectionParams = @{
                            ConnectionURI     = "http://{0}/powershell" -f $RemoteHost
                            ConfigurationName = 'Microsoft.Exchange'
                            Credential        = $creds
                            ErrorAction       = 'Stop'
                        }
                        $Global:PSExchangeRemote = New-PSSession @ConnectionParams
                    }
                    catch {
                        # Write a error message to the log.
                        $MessageParams = @{
                            Message     = "Unable to connect to {0} using Type {1}." -f $RemoteHost, $Type
                            ErrorAction = 'Stop'
                        }
                        Write-Error @MessageParams
                    }
                }
                "ExchangeHTTPS" {
                    try {
                        $ConnectionParams = @{
                            ConnectionURI     = "https://{0}/powershell" -f $RemoteHost
                            ConfigurationName = 'Microsoft.Exchange'
                            Credential        = $creds
                            ErrorAction       = 'Stop'
                        }
                        $Global:PSExchangeRemote = New-PSSession @ConnectionParams
                    }
                    catch {
                        # Write a error message to the log.
                        $MessageParams = @{
                            Message     = "Unable to connect to {0} using Type {1}." -f $RemoteHost, $Type
                            ErrorAction = 'Stop'
                        }
                        Write-Error @MessageParams
                    }
                }
                "SCP" {
                    $WinSCPSessionParams = @{
                        Credential                           = $creds
                        Hostname                             = $RemoteHost
                        Protocol                             = 'Scp'
                        GiveUpSecurityAndAcceptAnySshHostKey = $True
                    }
                    try {
                        $SessionOption = New-WinSCPSessionOption @WinSCPSessionParams
                        $Global:WinSCPSession = New-WinSCPSession -SessionOption $SessionOption
                        Write-Verbose -Message ("SCP Connection established with {0}" -f $Global:WinSCPSession.Hostname)
                    }
                    catch {
                        # Write a error message to the log.
                        $MessageParams = @{
                            Message     = "Unable to connect to {0} using Type {1}." -f $RemoteHost, $Type
                            ErrorAction = 'Stop'
                        }
                        Write-Error @MessageParams
                    }
                    # Check the Connection State
                    if (!($WinSCPSession.Opened)) {
                        # Check the connection state and find out if the session is still open.
                        $MessageParams = @{
                            Message     = "Connection to {0} using Type {1} was established. But now it seems to be lost!" -f $RemoteHost, $Type
                            ErrorAction = 'Stop'
                        }
                        Write-Error @MessageParams
                    }
                }
                default {
                    # Write a error message to the log.
                    $MessageParams = @{
                        Message     = "Unable to connect to {0} using Type {1}." -f $RemoteHost, $Type
                        ErrorAction = 'Stop'
                    }
                    Write-Error @MessageParams
                }
            }
        }
    }
}
