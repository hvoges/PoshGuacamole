Function Get-GuacamoleUsersGroup {
    param(
        [Parameter(Mandatory)]
        $AuthToken,

        [string]$Username        
    )
    
    $EndPoint = '{0}/api/session/data/{1}/users/{3}/userGroups?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username
    Invoke-WebRequest -Uri $EndPoint | ConvertFrom-Json

}