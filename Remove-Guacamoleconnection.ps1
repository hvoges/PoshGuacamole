Function Remove-GuacamoleConnection {
    param(
        [Parameter(Mandatory)]
        $AuthToken,

        [string]$ConnectionID
    )

    $EndPoint = '{0}/api/session/data/{1}/connections/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$ConnectionID

    Write-Verbose $Endpoint
    $Connections = Invoke-WebRequest -Uri $EndPoint -Method Delete
}