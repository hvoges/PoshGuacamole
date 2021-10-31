Function Get-GuacamoleConnectionParameter {
    param(
        [Parameter(Mandatory)]
        $AuthToken,

        [string]$ConnectionID
    )

    $EndPoint = '{0}/api/session/data/{1}/connections/{3}/parameters?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$ConnectionID

    Write-Verbose $Endpoint
    ( Invoke-WebRequest -Uri $EndPoint ).Content | ConvertFrom-Json
#    Foreach ( $Property  in  $Connections.psobject.properties ) {
#        $Connections.( $Property.name )
#    } | Sort-Object -Property Name
}