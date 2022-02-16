Function New-GuacamoleRdpConnection {
<#
.SYNOPSIS
    Createas a new Guacamole-Connections
.DESCRIPTION
    
.EXAMPLE
    PS C:\> New-GuacamoleConnection
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-13
#>    
    param(
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [Alias('Name','Connection')]                   
        [string]$Connectionname,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [Alias('ComputerName','Host','Computer')]
        [string]$Hostname,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$UserName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Password,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Domain,

        [Parameter(ValueFromPipelineByPropertyName)]
#       [ValidateSet($Timezone)]
        [string]$TimeZone = 'Europe/Berlin',

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ServerLayout = 'de-de-qwertz',

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$IgnoreCertificateWarning = 'true',
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('NLA','any','RDP','TLS','vmconnect')]
        [string]$SecurityMode = 'NLA',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('display-update','reconnect')]
        [string]$ResizeMethod = 'display-update',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1,65535)]
        [Int]$RdpPort = 3389,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RdpGatewayHostName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RdpGatewayUserName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RdpGatewayUserPassword,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RdpGatewayUserDomain,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1,65535)]
        [Int]$RdpGatewayPort,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Int]$MaximumConnections = 1,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ If ( $_ -gt $MaximumConnections ){ Throw "The number of connections per user cannot be greater then the number of maximum Connections"; $true }  })]
        [Int]$MaximumConnectionsPerUser = 1,

        $AuthToken = $GuacAuthToken
    )

    Process {
        $EndPoint = '{0}/api/session/data/{1}/connections?token={2}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$AuthToken.AuthToken

        If (-not ($ConnectionName))    
        {
            $ConnectionName = $Hostname
        }

        $Connection = [ordered]@{
            parentIdentifier = "ROOT"
            name = $Connectionname
            protocol = "rdp"
            parameters = [ordered]@{
            }
            attributes = [ordered]@{
            }
            }

        Switch ($PSBoundParameters.Keys) {
            "Connectionname"            { $Connection.parameters["Connectionname"]          = $PSBoundParameters["Connectionname"] }
            "hostname"                  { $Connection.parameters["hostname"]                = $PSBoundParameters["hostname"] }
            "username"                  { $Connection.parameters["username"]                = $PSBoundParameters["connectionName"] }
            "password"                  { $Connection.parameters["password"]                = $PSBoundParameters["Password"] }
            "domain"                    { $Connection.parameters["domain"]                  = $PSBoundParameters["domain"] }
            "timezone"                  { $Connection.parameters["timezone"]                = $PSBoundParameters["timezone"] }        
            "SecurityMode"              { $Connection.parameters["security"]                = $PSBoundParameters["SecurityMode"] }
            "IgnoreCertificateWarning"  { $Connection.parameters["ignore-cert"]             = $PSBoundParameters["IgnoreCertificateWarning"] }
            "ServerLayout"              { $Connection.parameters["server-layout"]           = $PSBoundParameters["ServerLayout"] }
            "ResizeMethod"              { $Connection.parameters["resize-method"]           = $PSBoundParameters["ResizeMethod"] }
            "RdpPort"                   { $Connection.parameters["Port"]                    = $PSBoundParameters["RdpPort"] }
            "RdpGatewayHostName"        { $Connection.parameters["gateway-hostname"]        = $PSBoundParameters["RdpGatewayHostname"] }
            "RdpGatewayUserName"        { $Connection.parameters["gateway-username"]        = $PSBoundParameters["RdpGatewayUserName"] }
            "RdpGatewayUserPassword"    { $Connection.parameters["gateway-password"]        = $PSBoundParameters["RdpGatewayUserPassword"] }
            "RdpGatewayUserDomain"      { $Connection.parameters["gateway-domain"]          = $PSBoundParameters["RdpGatewayUserdomain"] }                        
            "RdpGatewayPort"            { $Connection.parameters["gateway-port"]            = $PSBoundParameters["RdpGatewayPort"] }
            "MaximumConnections"        { $Connection.attributes["max-connections"]         = $PSBoundParameters["MaximumConnections"] }
            "MaximumConnectionsPerUser" { $Connection.attributes["max-connections-per-user"]= $PSBoundParameters["MaximumConnectionsPerUser"] }
        }
        $Connectionparameters = $Connection | ConvertTo-Json    
        # $Connectionparameters
        Write-Verbose $Endpoint
        # $Connections = Invoke-WebRequest -Uri $EndPoint -Method Post -ContentType 'application/json' -Body $Connectionparameters
    }
}

<#    $Connectionparameters = @"
    {
    "parentIdentifier": "ROOT",
    "name": "$ConnectionName",
    "protocol": "rdp",
    "parameters": {
        "port": "3389",
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
        "security": "",
        "disable-auth": "",
        "ignore-cert": "$IgnoreCertificateWarning",
        "gateway-port": "",
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
        "Connectionname": "$Connectionname",
        "password": "$Password",
        "domain": "$Domain",
        "gateway-hostname": "",
        "gateway-Connectionname": "",
        "gateway-password": "",
        "gateway-domain": "",
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
        "sftp-Connectionname": "",
        "sftp-password": "",
        "sftp-private-key": "",
        "sftp-passphrase": "",
        "sftp-root-directory": "",
        "sftp-directory": ""
    },
    "parameters": {
        "max-connections": "",
        "max-connections-per-Connection": "",
        "weight": "",
        "failover-only": "",
        "guacd-port": "",
        "guacd-encryption": "",
        "guacd-hostname": ""
    }
    }
"@ #>