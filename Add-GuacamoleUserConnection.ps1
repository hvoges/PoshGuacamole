Function Add-GuacamoleUserConnection {
<#
.SYNOPSIS
    Adds User-Permissions to us a Connection
.DESCRIPTION
    This Cmdlet adds Read-Permissions to a User for a Connection. You can add users to connections or connections to users. 
.EXAMPLE
    PS C:\> Add-GuacamoleUserConnection -Username DemoUser -ConnectionID 43
    Permits DemoUser the connection to connection 43
.EXAMPLE
    PS C:\> Add-GuacamoleUserConnection -Username DemoUser -ConnectionID Server1
    Permits DemoUser the connection to Server1
.EXAMPLE
    PS C:\> Get-GuacamoleConnection -ConnectionName Server1 | Add-GuacamoleUserConnection -Username DemoUser
    Pipes a Connection to Add-GuacamoleUserConnection
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2022-02-22
#>  
    param(
        # The Name of the User who shall use the Connection    
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$Username,

        # The Connection-ID the user shall be added to
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$ConnectionID,

        # The Name of the Connection-ID the user shall be added to
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('name')]
        [string[]]$ConnectionName,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Begin {
            $Connections = Get-GuacamoleConnection   
    }

    Process {
        If ( $ConnectionName -and ! $ConnectionID ) {
            $ConnectionId = ( $Connections | Where-Object -FilterScript { $_.name -eq $ConnectionName }).identifier
        }
        ElseIf ( $ConnectionID -notin $Connections.identifier ) {
            Throw "ConnectionID not valid"
        }

        $EndPoint = '{0}/api/session/data/{1}/users/{3}/permissions?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username
        $Command = @"
[
  {
    "op": "add",
    "path": "/connectionPermissions/$ConnectionId",
    "value": "READ"
  }
]
"@

        Write-Verbose $Endpoint
        Try {
            $Response = Invoke-RestMethod -Uri $EndPoint -Method Patch -Body $Command  -ContentType 'application/json' -UseBasicParsing -ErrorAction Stop
        }
        Catch {
            Throw $_
        }
    }
}