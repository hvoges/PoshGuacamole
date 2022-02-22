Function Get-GuacamoleUserConnection {
<#
.SYNOPSIS
    Returns all Connections a user can access
.DESCRIPTION
    Returns an individual or all Guacamole-Connections
.EXAMPLE
    PS C:\> Get-GuacamoleUserConnection -UserName John
    Returns a list of all Connections the user can access. 
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

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Begin {
        $ConnectionList = Get-GuacamoleConnection
    }
    
    Process {
        $EndPoint = '{0}/api/session/data/{1}/users/{3}/permissions?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username
        Write-Verbose $Endpoint

        Try {
            $Permissions = Invoke-RestMethod -Uri $EndPoint -UseBasicParsing -ErrorAction Stop
        }
        Catch {
            Throw $_
        }

        Foreach ( $ConnectionPerms in $Permissions.ConnectionPermissions.PSObject.Properties )
        {
            $Connection = $ConnectionList | Where-Object -FilterScript { $_.identifier -eq $ConnectionPerms.Name } 
            [PSCustomObject]@{
                ParentIdentifier = $Connection.ParentIdentifier
                Identifier = $ConnectionPerms.Name 
                ConnectionName = ( $ConnectionList | Where-Object -FilterScript { $_.identifier -eq $ConnectionPerms.Name } ).Name
                Protocol = $Connection.protocol
                ActiveConnections = $Connection.ActiveConnections
                Permission = $ConnectionPerms.Value
            }
        }
    }
}