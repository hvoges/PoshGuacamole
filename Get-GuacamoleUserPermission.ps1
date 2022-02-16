Function Get-GuacamoleUserPermission {
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
        [string]$Username,

        $AuthToken = $GuacAuthToken
    )

    Process {
        $EndPoint = '{0}/api/session/data/{1}/users/{3}/permissions?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$AuthToken.Username
        Write-Verbose $Endpoint
        $Permissions = Invoke-WebRequest -Uri $EndPoint | ConvertFrom-Json
        Foreach ( $Property in $Permissions.psobject.properties ) {
            Get-GuacamoleAttributes -Object ( $Permissions.($Property.Name) )
        } 
    }
}