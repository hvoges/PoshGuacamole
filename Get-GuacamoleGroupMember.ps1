Function Get-GuacamoleGroupMember {
<#
.SYNOPSIS
    Returns The Groups a User is member in
.DESCRIPTION
    Returns The Groups a User is member in
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
        $EndPoint = '{0}/api/session/data/{1}/users/{3}/userGroups?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$AuthToken.Username
        Try {
            Invoke-RestMethod -Uri $EndPoint -UseBasicParsing
        }
        Catch {
            Throw $_
        }
    }
}