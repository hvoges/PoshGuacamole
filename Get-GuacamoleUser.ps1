Function Get-GuacamoleUser {
<#
.SYNOPSIS
    Returns an individual or all Guacamole-Users
.DESCRIPTION
    Returns an individual or all Guacamole-Users
.EXAMPLE
    PS C:\> Get-GuacamoleUser 
    Returns all Guacamole-Users
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-13
#>    
    param(
        [Parameter(ValueFromPipeline,
        ValueFromPipelineByPropertyName)]
        [string]$Username,

        $AuthToken =$Global:GuacAuthToken
    )

    Process {
        if ( $Username ) {
            $EndPoint = '{0}/api/session/data/{1}/users/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username
        } 
        else {
            $EndPoint = '{0}/api/session/data/{1}/users?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken
        }

        Write-Verbose $Endpoint
        $userlist = Invoke-WebRequest -Uri $EndPoint | ConvertFrom-Json
        if ( $userlist.username ) {
            Get-GuacamoleAttributes -Object $userlist
        }
        Else {
            Foreach ( $Property in $UserList.psobject.properties ) {
                Get-GuacamoleAttributes -Object ( $UserList.($Property.Name) )
            } 
        }
    }
}