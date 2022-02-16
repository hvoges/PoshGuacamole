Function Get-GuacamoleConnectionParameter {
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
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('identifier')]
        [string]$ConnectionID,

        $AuthToken = $GuacAuthToken
    )

    process {
        $EndPoint = '{0}/api/session/data/{1}/connections/{3}/parameters?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$ConnectionID

        Write-Verbose $Endpoint
        ( Invoke-WebRequest -Uri $EndPoint ).Content | ConvertFrom-Json
    #    Foreach ( $Property  in  $Connections.psobject.properties ) {
    #        $Connections.( $Property.name )
    #    } | Sort-Object -Property Name
    }
}