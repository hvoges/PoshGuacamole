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
    Version: 1.1
    Date: 2022-01-15
#>    
    param(
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$Username,

        [Switch]$SkipEmptyAttributes,

        [Switch]$Raw,

        $AuthToken =$Global:GuacAuthToken
    )

    Process {
        if ( $Username ) {
            $EndPoint = '{0}/api/session/data/{1}/users/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username
        } 
        else {
            $EndPoint = '{0}/api/session/data/{1}/users?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken
        }

        if ( $SkipEmptyAttributes ) {
            $PSDefaultParameterValues=@{"Get-GuacamoleAttributes:SkipEmptyAttributes"=$True} 
        }

        Write-Verbose $Endpoint
        $userlist = Invoke-RestMethod -Uri $EndPoint
        if ( $PSBoundParameters.ContainsKey('Raw') ) { 
            $userlist
         }
        elseif ( $userlist.username ) {
            Get-GuacamoleAttributes -Object $userlist -SkipEmptyAttributes:$SkipEmptyAttributes
        }
        Else {
            Foreach ( $Property in $UserList.psobject.properties ) {
                Get-GuacamoleAttributes -Object ( $UserList.($Property.Name) )  -SkipEmptyAttributes:$SkipEmptyAttributes
            } 
        }
    }
}