Function Get-GuacamoleUserGroup {
<#
.SYNOPSIS
    Returns Guacamole Groups 
.DESCRIPTION
    Returns an individual or all Guacamole-Users
.EXAMPLE
    PS C:\> Get-GuacamoleUserGroup
    Returns all User-Groups
.NOTES
    Author: Holger Voges
    Version: 1.1
    Date: 2022-02-16
#>    
    param(
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$GroupName,

        $AuthToken = $GuacAuthToken
    )

    Process {
        if ( $GroupName ) {
            $EndPoint = '{0}/api/session/data/{1}/users/{3}/userGroups?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$GroupName
        }
        Else {
            $EndPoint = '{0}/api/session/data/{1}/userGroups?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken
        }

        Write-Verbose $Endpoint
        Try {
            Invoke-RestMethod -UseBasicParsing -Uri $EndPoint -ErrorAction Stop
        }
        Catch {
            Throw $_.Exception.Message
        }
    }
}