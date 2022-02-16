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
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$Username,

        [Switch]$SkipEmptyAttributes,

        [Switch]$Raw,

        $AuthToken = $GuacAuthToken
    )

    Process {
        if ( $Username ) {
            $EndPoint = '{0}/api/session/data/{1}/users/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username
        } 
        else {
            $EndPoint = '{0}/api/session/data/{1}/users?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken
        }

        Write-Verbose $Endpoint
        Try {
            $WebResponse = Invoke-WebRequest -Uri $EndPoint -ErrorAction Stop
        }
        Catch {
            Throw $_.Exception.Message
        }
        $UserList = $WebResponse | ConvertFrom-Json 
        if ( $PSBoundParameters.ContainsKey('Raw') ) { 
            $WebResponse.Content
         }
        elseif ( $UserList.username ) {
            Get-GuacamoleAttributes -Object $UserList -SkipEmptyAttributes:$SkipEmptyAttributes
        }
        Else {
            Foreach ( $Property in $UserList.psobject.properties ) {
                Get-GuacamoleAttributes -Object ( $UserList.($Property.Name) )  -SkipEmptyAttributes:$SkipEmptyAttributes
            } 
        }
    }
}