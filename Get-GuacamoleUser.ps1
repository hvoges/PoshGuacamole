Function Get-GuacamoleUser {
    param(
        [Parameter(Mandatory)]
        $AuthToken,

        [string]$Username
    )

    if ( $Username ) {
        $EndPoint = '{0}/api/session/data/{1}/users/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username
    } 
    else {
        $EndPoint = '{0}/api/session/data/{1}/users?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken
    }

    Write-Verbose $Endpoint
    $userlist = Invoke-WebRequest -Uri $EndPoint | ConvertFrom-Json
    Foreach ( $Property  in  $UserList.psobject.properties ) {
        $UserList.( $Property.name )
    } 
}