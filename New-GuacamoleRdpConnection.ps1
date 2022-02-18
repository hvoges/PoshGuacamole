Function New-GuacamoleRdpConnection {
<#
.SYNOPSIS
    Createas a new Guacamole-RDP-Connection.
.DESCRIPTION
    
.EXAMPLE
    PS C:\> $Password = Convertto-Securestring -String "2manySecrets!" -AsPlainText -force
    PS C:\> New-GuacamoleRdpConnection -Hostname Server1 -Username Administrator -Password $Password
    This Command creates a new RDP-Connection-Setting with the given values. Username and Password are
    the names with which Guacamole will log in to the Remote Computer. The Connection will automatically
    be named after the Computer.
.EXAMPLE
    PS C:\> $Password = Convertto-Securestring -String "2manySecrets!" -AsPlainText -force
    PS C:\> New-GuacamoleRdpConnection -Hostname Server1 -Username Administrator -Password $Password -OtherProperties @{"initial-program"="C:\windows\Notepad.exe"}
    This Command will set the inital programm. You can add further Properties inside the hashtable, but 
    the key-value-Pairs have to be separated by a semi-colon, eg. @{"sftp-username"="john";"sftp-password"="TopSecret!"}
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-13
#>    
    param(
        # The name of the target-Host as Computername or IP
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [Alias('ComputerName','Host','Computer')]
        [string]$Hostname,

        # The Connectionname, defaults to the Computer-Name
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Name','Connection')]                   
        [string]$Connectionname = $Hostname,

        # The RDP-Accountname 
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string]$UserName,

        # The RDP-Accountnames Password
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [securestring]$UserPassword,

        # The RDP-Accountnames Domain. Use Localhost if you want to authenticate locally. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Domain = 'LocalHost',

        # The Timezone for the RDP-Session
        [Parameter(ValueFromPipelineByPropertyName)]
#       [ValidateSet($Timezone)]
        [GuacamoleTimezones]$TimeZone = 'Europe_Berlin',

        # The Keyboard-Layout
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ServerLayout = 'de-de-qwertz',

        # Skip the Certificate-Warning if the https-Certificate is not trusted
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$IgnoreCertificateWarning = 'true',
        
        # The defaul securicty Mode for the Connection. NLA is default. 
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('NLA','any','RDP','TLS','vmconnect')]
        [string]$SecurityMode = 'NLA',

        # 
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('display-update','reconnect')]
        [string]$ResizeMethod = 'display-update',

        # The RDP-Port. Default is 3389
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1,65535)]
        [int]$RdpPort = 3389,

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

        # The maximum number of parallel RDP-Connections possible to this Host.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Int]$MaximumConnections = 1,

        # The maximum Connections per User. This value cannot be greater than MaximumConnections
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ If ( $_ -gt $MaximumConnections ){ Throw "The number of connections per user cannot be greater then the number of maximum Connections"; $true }  })]
        [Int]$MaximumConnectionsPerUser = 1,

        # Otherproperties can hold any configuration parameter. OtherProperties must be a 
        # hashtable in the form @{"parametername"="parametervalue"}. The Parameter-Name has to 
        # be in Qutation-Marks.
        [hashtable]$OtherProperties,

        $AuthToken = $GuacAuthToken
    )

    Process {
        $EndPoint = '{0}/api/session/data/{1}/connections?token={2}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$AuthToken.AuthToken
        Write-Verbose $Endpoint

        $Connection = [ordered]@{
            parentIdentifier = "ROOT"
            name = $Connectionname
            protocol = "rdp"
            parameters = [ordered]@{
            }
            attributes = [ordered]@{
            }
        }

        If ( $UserPassword )
        {   
            $UserPasswordUnprotected = ([pscredential]::new('User',$UserPassword)).GetNetworkCredential().Password
        }
        If ( $RdpGatewayUserPassword )
        {   
            $RdpGatewayPasswordUnprotected = ([pscredential]::new('User',$RdpGatewayUserPassword)).GetNetworkCredential().Password
        }

        $Connectionparameters = @"
{
    "parentIdentifier": "ROOT",
    "name": "$ConnectionName",
    "protocol": "rdp",
    "parameters": {
        "port": "$RdpPort",
        "read-only": "",
        "swap-red-blue": "",
        "cursor": "",
        "color-depth": "",
        "clipboard-encoding": "",
        "disable-copy": "",
        "disable-paste": "",
        "dest-port": "",
        "recording-exclude-output": "",
        "recording-exclude-mouse": "",
        "recording-include-keys": "",
        "create-recording-path": "",
        "enable-sftp": "",
        "sftp-port": "",
        "sftp-server-alive-interval": "",
        "enable-audio": "",
        "security": "$SecurityMode",
        "disable-auth": "",
        "ignore-cert": "$IgnoreCertificateWarning",
        "gateway-port": $RdpGatewayPort,
        "server-layout": "$ServerLayout",
        "timezone": "$TimeZone",
        "console": "",
        "width": "",
        "height": "",
        "dpi": "",
        "resize-method": "$ResizeMethod",
        "console-audio": "",
        "disable-audio": "",
        "enable-audio-input": "",
        "enable-printing": "",
        "enable-drive": "",
        "create-drive-path": "",
        "enable-wallpaper": "",
        "enable-theming": "",
        "enable-font-smoothing": "",
        "enable-full-window-drag": "",
        "enable-desktop-composition": "",
        "enable-menu-animations": "",
        "disable-bitmap-caching": "",
        "disable-offscreen-caching": "",
        "disable-glyph-caching": "",
        "preconnection-id": "",
        "hostname": "$Hostname",
        "username": "$UserName",
        "password": "$UserPasswordUnprotected",
        "domain": "$Domain",
        "gateway-hostname": "$RdpGatewayHostName",
        "gateway-username": "$RdpGatewayUserName",
        "gateway-password": "$RdpGatewayPasswordUnprotected",
        "gateway-domain": "$RdpGatewayUserDomain",
        "initial-program": "",
        "client-name": "",
        "printer-name": "",
        "drive-name": "",
        "drive-path": "",
        "static-channels": "",
        "remote-app": "",
        "remote-app-dir": "",
        "remote-app-args": "",
        "preconnection-blob": "",
        "load-balance-info": "",
        "recording-path": "",
        "recording-name": "",
        "sftp-hostname": "",
        "sftp-host-key": "",
        "sftp-username": "",
        "sftp-password": "",
        "sftp-private-key": "",
        "sftp-passphrase": "",
        "sftp-root-directory": "",
        "sftp-directory": ""
    },
    "attributes": {
        "max-connections": "",
        "max-connections-per-Connection": "",
        "weight": "",
        "failover-only": "",
        "guacd-port": "",
        "guacd-encryption": "",
        "guacd-hostname": ""
    }
}
"@ 

        if ( $OtherProperties ) {
            Foreach ( $Property in $OtherProperties.GetEnumerator() )
            {
                $SearchValue = '"{0}": ""' -f $Property.key
                $ReplacementValue = '"{0}": "{1}"' -f $Property.key,$Property.Value
                $Connectionparameters = $Connectionparameters -replace $Searchvalue,$ReplacementValue
            }
        }

        Try {
            $Connections = Invoke-WebRequest -Uri $EndPoint -Method Post -ContentType 'application/json' -Body $Connectionparameters
        }
        Catch {
            Throw $_
        }
    }
}