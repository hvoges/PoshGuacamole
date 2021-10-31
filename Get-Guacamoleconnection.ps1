Function Get-GuacamoleConnection {
    param(
        [Parameter(Mandatory)]
        $AuthToken,

        [string]$ConnectionID
    )

    if ( $ConnectionID ) {
        $EndPoint = '{0}/api/session/data/{1}/connections/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$ConnectionID
    } 
    else {
        $EndPoint = '{0}/api/session/data/{1}/connections?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken
    }

    Write-Verbose $Endpoint
    $Connections = Invoke-WebRequest -Uri $EndPoint | ConvertFrom-Json
    Foreach ( $Property  in  $Connections.psobject.properties ) {
        $Connections.( $Property.name )
    } 
}