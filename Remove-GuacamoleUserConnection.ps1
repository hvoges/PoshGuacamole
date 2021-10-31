Function Remove-GuacamoleUserConnection {
    param(
        [Parameter(Mandatory)]
        $AuthToken,

        [string]$Username,

        [string]$ConnectionID
    )

    $EndPoint = '{0}/api/session/data/{1}/users/{3}/permissions?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username

    $Command = @"
[
  {
    "op": "remove",
    "path": "/connectionPermissions/$ConnectionId",
    "value": "READ"
  }
]
"@

    Write-Verbose $Endpoint
    $Response = Invoke-WebRequest -Uri $EndPoint -Method Patch -Body $Command | ConvertFrom-Json
}