Function Set-GuacamoleRdpConnection {
    <#
    .SYNOPSIS
        Changes the Configuration of exisiting RDP-Connections
    .DESCRIPTION
        Set-GuacamoleRdpConnection can change all exisiting RDP-Connections. The Cmdlet changes only the given values, 
        all current settings are kept. You have to enter the Connectionname or ID to identify the configuration you 
        want to change. If you want to change the Configuration-Name, use the Configuration-ID as the Identifier.
    .EXAMPLE
        PS C:\> Set-GuacamoleRdpConnection -ConnectionName Server1 -ServerLayout English_US -IgnoreCertificateWarning $true
        This Example changes the Connection named Server1. The Serverlayout is changed to English (US) and Certificate-Warnings
        will be ignored. 
    .EXAMPLE
        PS C:\> $Password = Convertto-Securestring -String "2manySecrets!" -AsPlainText -force
        PS C:\> Set-GuacamoleRdpConnection -Hostname Server1 -Username Administrator -Password $Password
        These Command will will set the RDP-Username to Administrator and the Password to 2manySecrets!
    .NOTES
        Author: Holger Voges
        Version: 1.0 
        Date: 2022-02-21
    #> 
    [CmdletBinding(SupportsShouldProcess)]    
    param(
        # The Name of the RDP-Host
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Computername','Host','Computer')]                   
        [string]$Hostname,

        # The Name of the Connection, will be used as default for the Host-Name if none is given
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Name','Connection')]                   
        [string]$Connectionname = $Hostname,

        # The unique ID of the Connection. If a connection-name if given, an ID is not required. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias()]                   
        [int]$ConnectionID,        
        
        # The RDP-Port. Default is 3389
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1,65535)]
        [int]$RdpPort,        

        # The username to use to authenticate. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$UserName,

        # The password to use when attempting authentication. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [securestring]$UserPassword,

        # The domain to use when attempting authentication. Use Localhost if you want to authenticate locally. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$UserDomain,

        # The Keyboard-Layout
        [Parameter(ValueFromPipelineByPropertyName)]
        [KeyboardLayout]$ServerLayout,

        # Skip the Certificate-Warning if the https-Certificate is not trusted
        [Parameter(ValueFromPipelineByPropertyName)]
        [Bool]$IgnoreCertificateWarning,
        
        # The defaul securicty Mode for the Connection. NLA is default. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('nla','nla-ext','any','rdp','tls','vmconnect')]
        [string]$SecurityMode='nla-ext',

        # 
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('display-update','reconnect')]
        [string]$ResizeMethod,

        # Whether this connection should only use lossless compression for graphical updates
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('force-lossless')]
        [Bool]$ForceLossles,

        # The Useraccount for validation against the RDP-Gateway
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RdpGatewayUserName,

        # The RDP-Gateway-Users Password as Secure String
        [Parameter(ValueFromPipelineByPropertyName)]
        [securestring]$RdpGatewayUserPassword,

        # The RDP-Gateway-Users Domain
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RdpGatewayUserDomain,

        # The Port on which the RDP-Gateway is listening (normally 443)
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1,65535)]
        [Int]$RdpGatewayPort,

        # The timezone is detected and will be passed to the server during the handshake phase of the connection, and may used by protocols, 
        # like RDP, that support it. This parameter can be used to override the value detected and passed during the handshake.
        [Parameter(ValueFromPipelineByPropertyName)]
        [GuacamoleTimezones]$TimeZone,

        # the name guacamole will provide as client-name to the RDP-Server
        [string]$ClientName,

        # The maximum number of parallel RDP-Connections possible to this Host.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Int]$MaxConnections = 1,

        # The maximum Connections per User. This value cannot be greater than MaximumConnections
        [Parameter(ValueFromPipelineByPropertyName)]
        # [ValidateScript({ If ( $_ -gt $MaximumConnections ){ Throw "The number of connections per user cannot be greater then the number of maximum Connections"}; $true })]
        [Int]$MaxConnectionsPerUser = 1,

        # The full path to the program to run immediately upon connecting.
        [Parameter(ValueFromPipelineByPropertyName)]
        [alias('initial-program')]        
        [String]$InitialProgram,

        # If set to “true”, you will be connected to the console (admin) session of the RDP server. Only valid till Windows Server 2003
        [Parameter(ValueFromPipelineByPropertyName)]
        [alias('console')]        
        [string]$ConnectToConsole,
        
        # The width of the display to request. If unspecified, connecting client settings will be used. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$ScreenWidth,

        # The height of the display to request. If unspecified, connecting client settings will be used. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$ScreenHeight,

        # The effective resolution of the client display. If not specified, the resolution and size of the client display will be used to determine an appropriate resolution
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$DpiScreenResolution,
        
        # The color depth to request, in bits-per-pixel.
        [Validateset('8','16','24')]
        [int]$ColorDepth,
        
        # If set to “true”, no input will be accepted on the connection at all. Users will only see the desktop and whatever other users using that same desktop are doing.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$ScreenReadOnly,

        # Clipboard-text copied within the remote desktop session will not be accessible by the user at the browser side of the Guacamole session if set to True.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$DisableCopy,
        
        # Clipboard-text copied at the browser side of the Guacamole session will not be accessible within the remote ddesktop session if set to true. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$DisablePaste,

        # If set to “true”, audio will be explicitly enabled in the console (admin) session of the RDP server. Admin-Console is only available till Server 2003.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$ConsoleAudio,

        # If you are concerned about bandwidth usage, or sound is causing problems, you can explicitly disable sound by setting this parameter to “true”
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$DisableAudio,

        # If set to “true”, audio input support (microphone) will be enabled, leveraging the standard “AUDIO_INPUT” channel of RDP.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnableAudioInput,

        # With printing enabled, RDP users can print to a virtual printer. Printing support requires GhostScript to be installed on the Guacamole-Server.  
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnablePrinting,

        # This is the name that the user will see in, for example, the Devices and Printers control panel.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RedirectedPrinterName,
        
        # With file transfer enabled, RDP users can transfer files to and from a virtual drive. Files will be stored in the directory specified by the “drive-path” parameter, which is required if file transfer is enabled.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnableDrive,

        # This is the name that users will see in their Computer/My Computer area along with client name (for example, “Guacamole on Guacamole RDP”)
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RedirDriveName,
        
        # If set to true downloads from the remote server to client (browser) will be disabled. This includes both downloads done via the hidden Guacamole menu, 
        # as well as using the special “Download” folder presented to the remote server.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$RedirDriveDisableDownload,
        
        # If set to true, uploads from the client (browser) to the remote server location will be disabled.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$RedirDriveDisableUpload,

        # The directory on the Guacamole server in which transferred files should be stored. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RedirDrivePath,

        # If set to “true”, and file transfer is enabled, the directory specified by the drive-path parameter will automatically be created if it does not yet exist. 
        # Only the final directory in the path will be created - if other directories earlier in the path do not exist, automatic creation will fail
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$CreateDrivepath, 
        
        # A comma-separated list of static channel names to open and expose as pipes. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$StaticChanels,
        
        # If set to “true”, enables rendering of the desktop wallpaper. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnableWallPaper,

        # If set to “true”, enables use of theming of windows and controls. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnableTheming,

        # If set to “true”, text will be rendered with smooth edges. Text over RDP is rendered with rough edges by default, as this reduces the number of colors used by text.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnableFontSmooting,
        
        # If set to “true”, the contents of windows will be displayed as windows are moved. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnableWindowDrag,

        # If set to “true”, graphical effects such as transparent windows and shadows will be allowed. (Windows Aero)
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnableDesktopComposition, 

        # If set to “true”, graphical effects such as transparent windows and shadows will be allowed
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnableMenuAnimations,

        # In certain situations, particularly with RDP server implementations with known bugs, it is necessary to disable RDP’s built-in bitmap caching functionality.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$DisableBitmapCaching,

        # RDP normally maintains caches of regions of the screen that are currently not visible in the client in order to accelerate retrieval of those regions when they come into view.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$DisableOffscreenCaching,

        # In addition to screen regions, RDP maintains caches of frequently used symbols or fonts, collectively known as “glyphs.” Glyph caching is currently universally disabled! (2022-02-21)
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$DisableGlypCaching,
        
        # Specifies the RemoteApp to start on the remote desktop. If supported by your remote desktop server, this application, and only this application, will be visible to the user.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RemoteApp,
        
        # The working directory, if any, for the remote application
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RemoteAppDir,
        
        # The command-line arguments, if any, for the remote application. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RemoteAppArgs,

        # The numeric ID of the RDP source. This is a non-negative integer value dictating which of potentially several logical RDP connections should be used. If using Hyper-V, this should be left blank.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$PreconnectionID,

        # An arbitrary string which identifies one of potentially several logical RDP connections hosted by the same RDP server. For Hyper-V, this will be the ID of the destination virtual machine.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$VmID,

        # The load balancing information or cookie which should be provided to the rdp connection broker. If no connection broker is being used, this should be left blank.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LoadBalanceInfo,

        # The directory in which screen recording files should be created. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RecordingPath,
        
        # The filename to use for any created recordings.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RecordingName,

        # If set to “true”, graphical output and other data normally streamed from server to client will be excluded from the recording, producing a recording which contains only user input events.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$RecExcludeOutPut,

        # If set to “true”, user mouse events will be excluded from the recording, producing a recording which lacks a visible mouse cursor.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$RecExcludeMouse,
 
        # If set to “true”, user key events will be included in the recording. The recording can subsequently be passed through the guaclog utility to produce a transcript. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$RecIncludeKeys,

        # If set to “true”, the directory specified by the recording-path parameter will automatically be created if it does not yet exist. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$CreateRecordingPath,

        # If set to “true”, the user will be allowed to upload or download files from the specified server using SFTP.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnableSftp,

        # The hostname or IP address of the server hosting SFTP. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SftpHostname,

        # The port the SSH server providing SFTP is listening on, usually 22.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SftpPort,

        # The known hosts entry for the SFTP server. The format of this parameter is that of a single entry from an OpenSSH known_hosts file.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SftpHostKey,

        # The username to authenticate as when connecting to the specified SSH server for SFTP.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SftUsername,

        # The password to use when authenticating with the specified SSH server for SFTP.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SftPassword,

        # The entire contents of the private key to use for public key authentication. The private key must be in OpenSSH format, as would be generated by the OpenSSH ssh-keygen utility.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SftPrivatekey,
        
        # The passphrase to use to decrypt the private key for use in public key authentication. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SftpPassPhrase,

        # The directory to expose to connected users via Guacamole’s Using the file browser.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SftpRoot,

        # The directory to upload files to if they are simply dragged and dropped,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$SftpDirectory,

        # The interval in seconds at which to send keepalive packets to the SSH server for the SFTP connection. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$SftpServerAliveInterval,

        # If set to true downloads from the remote system to the client (browser) will be disabled.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$SftpDisableDownload,

        # If set to true uploads from the client (browser) to the remote system will be disabled. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$SftpDisableUpload,
        
        # If set to “true”, Guacamole will attempt to send the Wake-On-LAN packet prior to establishing a connection.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$WolEnable,

        # This parameter configures the MAC address that Guacamole will use in the magic WoL packet to attempt to wake the remote system.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$WolMacAddr,

        # This parameter configures the multicast address that Guacamole will send the WoL packet to in order to wake the host.  If no value is provided, the default local IPv4 broadcast address (255.255.255.255) will be used.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$WolBroadcastAddr,

        # Setting this parameter to a positive value will cause Guacamole to wait the specified number of seconds before attempting the initial connection.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$WolWaitTimer,

        [int]$Weight,
        
        [bool]$FailoverOnly,

        # The host the Guacamole proxy daemon (guacd) is listening on. If omitted, Guacamole will assume guacd is listening on localhost.
        [string]$guacdHostname,
        
        # The port the Guacamole proxy daemon (guacd) is listening on (default 4822)
        [UInt16]$GuacdPort,

        [validateSet('ssl','none')]
        [string]$GuacdEncryption,
        
        $AuthToken = $GuacAuthToken
    )
 
    Begin {
        # Cache a Connectionlist upfront to reduce number of calls
        Try {
            $ConnectionList = Get-GuacamoleConnection -protocol RDP
        }
        Catch {
            Throw $_
        }
    }

    Process {
        # Check if Hostname or ConnectionID are set. As the Pipeline-Input can contain both, a mandatory Parameterset is not possible
        if ( $ConnectionID ) {
            $Connection = $ConnectionList | Where-Object -FilterScript { $_.identifier -eq $ConnectionID }
        }
        elseif ( $ConnectionName ) {
            $Connection = $ConnectionList | Where-Object -FilterScript { $_.name -eq $Connectionname }
        }
        Else {
            Throw "A valid Connection-Name or ConnectionID is mandatory"
        }

        # if $Connectionlist does not contain an entry for the Connection-ID or Hostname
        If (-not $Connection )
        {
            Throw "Hostname or Computername could not be found"
        }

        # Convert the parameter- and Attribute-Sets to a Hashtable. 
        $ConnectionParameter = ConvertTo-HashTable -JsonString ( Get-GuacamoleConnectionParameter -ConnectionID $Connection.identifier ).attributes  
        $ConnectionAttribute = ConvertTo-HashTable -InputObject $Connection.Attributes      

        # Scan through the List of entered Function-Parameters and add them to the Parameter- and Attributes-Hashtable
        Switch ($PSBoundParameters.Keys) 
        {
            "EmailAddress"               { $connectionParameter."guac-email-address"         = $EmailAddress }
            "Disabled"                   { $connectionParameter."disabled"                   = $Disabled }
            "Hostname"                   { $connectionParameter."hostname"                   = $Hostname }
            "RdpPort"                    { $connectionParameter."port"                       = $RdpPort }
            # AuthenticatiparametersParameter  
            "Username"                   { $connectionParameter."username"                   = $UserName } 
            "UserPassword"               { $connectionParameter."password"                   = $([pscredential]::new('User',$UserPassword)).GetNetworkCredential().Password }
            "UserDomain"                 { $connectionParameter."domain"                     = $UserDomain }
            "SecurityMode"               { $connectionParameter."security"                   = $SecurityMode }
            "DisableAuth"                { $connectionParameter."disable-auth"               = $DisableAuth }
            "IgnoreCertificateWarning"   { $connectionParameter."ignore-cert"                = $IgnoreCertificateWarning }
            # RDP GatewaparametersParameter  
            "RdpGatewayHostName"         { $connectionParameter."gateway-hostname"           = $RdpGatewayHostName }
            "GatewayPort"                { $connectionParameter."gateway-port"               = $GatewayPort }
            "RdpGatewayUserName"         { $connectionParameter."gateway-username"           = $RdpGatewayUserName }
            "RdpGatewayUserPassword"     { $connectionParameter."gateway-password"           = ([pscredential]::new('User',$RdpGatewayUserPassword)).GetNetworkCredential().Password }
            "RdpGatewayUserDomain"       { $connectionParameter."gateway-domain"             = $RdpGatewayUserDomain }
            # Base SettinparametersParameter  
            "InitialProgram"             { $connectionParameter."initial-program"            = $InitialProgram }
            "ClientName"                 { $connectionParameter."client-name"                = $ClientName }
            "ServerLayout"               { $connectionParameter."server-layout"              = $KeyboardCodes."$ServerLayout" }
            "Timezone"                   { $connectionParameter."timezone"                   = $Timezone }
            "ConnectToConsole"           { $connectionParameter."console"                    = $ConnectToConsole }
            # SreenparametersParameter  
            "ScreenWidth"                { $connectionParameter."width"                      = $ScreenWidth }
            "ScreenHeight"               { $connectionParameter."height"                     = $ScreenHeight }
            "DpiScreenResolution"        { $connectionParameter."dpi"                        = $DpiScreenResolution }
            "ColorDepth"                 { $connectionParameter."color-depth"                = $ColorDepth }
            "ResizeMethod"               { $connectionParameter."resize-method"              = $ResizeMethod }
            "ForceLossLess"              { $connectionParameter."force-lossless"             = $ForceLossles }
            "ScreenReadOnly"             { $connectionParameter."read-only"                  = $ScreenReadOnly }
            # ClipboaparametersParameter  
            "DisableCopy"                { $connectionParameter."disable-copy"               = $DisableCopy }
            "DisablePaste"               { $connectionParameter."disable-paste"              = $DisablePaste }
            # Device RedirectiparametersParameter  
            "ConsoleAudio"               { $connectionParameter."console-audio"              = $ConsoleAudio }
            "DisableAudio"               { $connectionParameter."disable-audio"              = $DisableAudio }
            "EnableAudioInput"           { $connectionParameter."enable-audio-input"         = $EnableAudioInput }
            "EnablePrinting"             { $connectionParameter."enable-printing"            = $EnablePrinting }
            "RedirectedPrinterName"      { $connectionParameter."printer-name"               = $RedirectedPrinterName }
            "EnableDrive"                { $connectionParameter."enable-drive"               = $EnableDrive }
            "RedirDriveName"             { $connectionParameter."drive-name"                 = $RedirDriveName }
            "RedirDriveDisableDownload"  { $connectionParameter."disable-download"           = $RedirDriveDisableDownload }
            "RedirDriveDisableUpload"    { $connectionParameter."disable-upload"             = $RedirDriveDisableUpload }
            "RedirDrivePath"             { $connectionParameter."drive-path"                 = $RedirDrivePath }
            "CreateDrivepath"            { $connectionParameter."create-drive-path"          = $CreateDrivepath }
            "StaticChanels"              { $connectionParameter."static-channels"            = $StaticChanels }
            # SpeparametersParameter  
            "EnableWallPaper"            { $connectionParameter."enable-wallpaper"           = $EnableWallPaper }
            "EnableTheming"              { $connectionParameter."enable-theming"             = $EnableTheming }
            "EnableFontSmooting"         { $connectionParameter."enable-font-smoothing"      = $EnableFontSmooting }
            "EnableWindowDrag"           { $connectionParameter."enable-full-window-drag"    = $EnableWindowDrag }
            "EnableDesktopComposition"   { $connectionParameter."enable-desktop-composition" = $EnableDesktopComposition }
            "EnableMenuAnimations"       { $connectionParameter."enable-menu-animations"     = $EnableMenuAnimations }
            "DisableBitmapCaching"       { $connectionParameter."disable-bitmap-caching"     = $DisableBitmapCaching }
            "DisableOffscreenCaching"    { $connectionParameter."disable-offscreen-caching"  = $DisableOffscreenCaching }
            "DisableGlypCaching"         { $connectionParameter."disable-glyph-caching"      = $DisableGlypCaching }
            # Remote ApparametersParameter  
            "RemoteApp"                  { $connectionParameter."remote-app"                 = $RemoteApp }
            "RemoteAppDir"               { $connectionParameter."remote-app-dir"             = $RemoteAppDir }
            "RemoteAppArgs"              { $connectionParameter."remote-app-args"            = $RemoteAppArgs }
            # HyperparametersParameter  
            "HyperVHost"                 { $connectionParameter."preconnection-id"           = $PreconnectionID }
            "VmID"                       { $connectionParameter."preconnection-blob"         = $VmID }
            # Load BalancinparametersParameter  
            "LoadBalanceInfo"            { $connectionParameter."load-balance-info"          = $LoadBalanceInfo }
            # Screen RecordinparametersParameter  
            "RecordingPath"              { $connectionParameter."recording-path"             = $RecordingPath }
            "RecordingName"              { $connectionParameter."recording-name"             = $RecordingName }
            "RecExcludeOutPut"           { $connectionParameter."recording-exclude-output"   = $RecExcludeOutPut }
            "RecExcludeMouse"            { $connectionParameter."recording-exclude-mouse"    = $RecExcludeMouse }
            "RecIncludeKeys"             { $connectionParameter."recording-include-keys"     = $RecIncludeKeys }
            "RecordingPath"              { $connectionParameter."create-recording-path"      = $CreateRecordingPath  }
            # SftparametersParameter  
            "EnableSftp"                 { $connectionParameter."enable-sftp"                = $EnableSftp }
            "SftpHostname"               { $connectionParameter."sftp-hostname"              = $SftpHostname }
            "SftpPort"                   { $connectionParameter."sftp-port"                  = $SftpPort }
            "SftpHostKey"                { $connectionParameter."sftp-host-key"              = $SftpHostKey }
            "SftUsername"                { $connectionParameter."sftp-username"              = $SftUsername }
            "SftPassword"                { $connectionParameter."sftp-password"              = $SftPassword }
            "SftPrivatekey"              { $connectionParameter."sftp-private-key"           = $SftPrivatekey }
            "SftpPassPhrase"             { $connectionParameter."sftp-passphrase"            = $SftpPassPhrase }
            "SftpRoot"                   { $connectionParameter."sftp-root-directory"        = $SftpRoot }
            "SftpDirectory"              { $connectionParameter."sftp-directory"             = $SftpDirectory }
            "SftpServerAliveInterval"    { $connectionParameter."sftp-server-alive-interval" = $SftpServerAliveInterval }
            "SftpDisableDownload"        { $connectionParameter."sftp-disable-download"      = $SftpDisableDownload }
            "SftpDisableUpload"          { $connectionParameter."sftp-disable-upload"        = $SftpDisableUpload }
            # WparametersParameter  
            "WolEnable"                  { $connectionParameter."wol-send-packet=true"       = $WolEnable }
            "WolMacAddr"                 { $connectionParameter."wol-mac-addr"               = $WolMacAddr }
            "WolBroadcastAddr"           { $connectionParameter."wol-broadcast-addr"         = $WolBroadcastAddr }
            "WolWaitTimer"               { $connectionParameter."wol-wait-time"              = $WolWaitTparameters }
            # Attributes
            "max-connections"            { $ConnectionAttribute."max-connections"           = $MaxConnections }
            "max-connections-per-user"   { $ConnectionAttribute."max-connections-per-user"  = $MaxConnectionsPerUser }
            "weight"                     { $ConnectionAttribute."weight"                    = $Weight }
            "failover-only"              { $ConnectionAttribute."failover-only"             = $FailoverOnly }
            "guacd-port"                 { $ConnectionAttribute."guacd-port"                = $GuacdPort }
            "guacd-encryption"           { $ConnectionAttribute."guacd-encryption"          = $GuacdEncryption }
            "guacd-hostname"             { $ConnectionAttribute."guacd-hostname"            = $guacdHostname }
        }
                  
        # Create a new JSON Request-Body from the entered Values
        $ConnectionHashTable = [ordered]@{
            parentIdentifier = $Connection.parentIdentifier
            name = if ($ConnectionName) { $ConnectionName } else { $Connection.name }
            identifier = $Connection.identifier
            protocol = "rdp"
            parameters = $ConnectionParameter
            attributes = $ConnectionAttribute
        } 
        
        $RequestBody  = $ConnectionHashTable | Convertto-Json         

        $EndPoint = '{0}/api/session/data/{1}/connections/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$AuthToken.AuthToken,$Connection.identifier
        Write-Verbose $Endpoint

        Try {
            $Connections = Invoke-WebRequest -Uri $EndPoint -Method Put -ContentType 'application/json' -Body $RequestBody
        }
        Catch {
            Throw $_
        }

    }
}
