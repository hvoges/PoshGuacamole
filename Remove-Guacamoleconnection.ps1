Function Remove-GuacamoleConnection {
<#
.SYNOPSIS
    Removes one or several Connections
.DESCRIPTION
    Removes one or several Connections. This Cmdlet makes no difference
    between the types of connections and can use pipeline-Input
.EXAMPLE
    PS C:\> Remove-GuacamoleConnection -ConnectionID 47
    Returns the Connection-Settings for the Connection PC12
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 202-02-18
#>    
    param(
        # The ID of the Connection you want to remove
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Identifier')]
        [string]$ConnectionID,

        # The Name of the Connection you want to remove
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('name')]
        [string]$ConnectionName,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken        
    )

    Begin {
            $connections = Get-GuacamoleConnection
    }

    Process {
        if (( ! $ConnectionID ) -and (! $ConnectionName )) {
            Throw "Please Call this Cmdlet with a Connection-ID or a Connection-Name"
        }
        ElseIf ( ! $ConnectionID ) {
            $ConnectionID = ( $connections | Where-Object { $_.name -eq $Connectionname  } ).identifier
        }

        Try {
            $EndPoint = '{0}/api/session/data/{1}/connections/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$ConnectionID
        }
        Catch {
            Throw $_
        }

        Write-Verbose $Endpoint
        $Connections = Invoke-WebRequest -Uri $EndPoint -Method Delete
    }
}