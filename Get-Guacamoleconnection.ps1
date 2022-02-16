Function Get-GuacamoleConnection {
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
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$ConnectionID,
        
        $AuthToken = $GuacAuthToken
    )

    Process {    
        if ( $ConnectionID ) {
            $EndPoint = '{0}/api/session/data/{1}/connections/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$ConnectionID
        } 
        else {
            $EndPoint = '{0}/api/session/data/{1}/connections?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken
        }

        Write-Verbose $Endpoint
        $ConnectionList = Invoke-WebRequest -Uri $EndPoint | ConvertFrom-Json
        If ( $ConnectionList.Name ) {
            Get-GuacamoleAttributes -Object $connectionList
        }
        Else {
            Foreach ( $Property in $ConnectionList.psobject.properties ) {
                Get-GuacamoleAttributes -Object ( $ConnectionList.( $Property.name ))
            }
        }
    }
}