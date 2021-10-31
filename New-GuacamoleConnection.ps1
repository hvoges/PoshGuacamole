Function New-GuacamoleConnection {
    param(
        [Parameter(Mandatory)]
        $AuthToken,

        [string]$Connectionname,

        [string]$Hostname,

        [string]$TimeZone = 'Europe/Berlin',

        [string]$ServerLayout = 'de-de-qwertz',

        [string]$Username = 'Student',

        [string]$Password = 'Passw0rd',

        [string]$Domain = 'netz-weise',

        [string]$IgnoreCertificateWarning = 'true',

        [string]$ResizeMethod = 'display-update'
    )

    $EndPoint = '{0}/api/session/data/{1}/connections?token={2}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$AuthToken.AuthToken

    If (-not ($ConnectionName))    
    {
        $ConnectionName = $Hostname
    }

$ConnectionAttributes = @"
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
    "username": "$Username",
    "password": "$Password",
    "domain": "$Domain",
    "gateway-hostname": "",
    "gateway-username": "",
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
    "sftp-username": "",
    "sftp-password": "",
    "sftp-private-key": "",
    "sftp-passphrase": "",
    "sftp-root-directory": "",
    "sftp-directory": ""
},
"attributes": {
    "max-connections": "",
    "max-connections-per-user": "",
    "weight": "",
    "failover-only": "",
    "guacd-port": "",
    "guacd-encryption": "",
    "guacd-hostname": ""
}
}
"@

    Write-Verbose $Endpoint
    $Connections = Invoke-WebRequest -Uri $EndPoint -Method Post -ContentType 'application/json' -Body $ConnectionAttributes
}