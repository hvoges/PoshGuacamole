Function Add-GuacamoleUserConnection {
<#
.SYNOPSIS
    Returns an individual or all Guacamole-Connections
.DESCRIPTION
    Returns an individual or all Guacamole-Connections
.EXAMPLE
    PS C:\> Get-GuacamoleConnection -ConnectionID PC12
    Returns the Connection-Settings for the Connection PC12
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-13
#>  
    param(
        [string]$Username,

        [string]$ConnectionID,

        $AuthToken = $GuacAuthToken
    )

    $EndPoint = '{0}/api/session/data/{1}/users/{3}/permissions?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username

    $Command = @"
[
  {
    "op": "add",
    "path": "/connectionPermissions/$ConnectionId",
    "value": "READ"
  }
]
"@

    Write-Verbose $Endpoint
    $Response = Invoke-WebRequest -Uri $EndPoint -Method Patch -Body $Command | ConvertFrom-Json
}