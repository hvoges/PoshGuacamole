Function Get-GuacamoleUserHistory {
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

        $AuthToken = $GuacAuthToken
    )

    Process {
        $EndPoint = '{0}/api/session/data/{1}/users/{3}/history?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username

        Write-Verbose $Endpoint
        Try {
            Invoke-RestMethod -UseBasicParsing -Uri $EndPoint -ErrorAction Stop
        }
        Catch {
            Throw $_.Exception.Message
        }
    }
}