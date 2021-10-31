Function Get-GuacamoleUserPermission {
    param(
        [Parameter(Mandatory)]
        $AuthToken,

        [string]$Username
    )

    $EndPoint = '{0}/api/session/data/{1}/users/{3}/permissions?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username
    Write-Verbose $Endpoint
    Invoke-WebRequest -Uri $EndPoint | ConvertFrom-Json
}