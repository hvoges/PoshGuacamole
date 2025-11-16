Function Stop-GuacamoleActiveConnection {
    <#
    .SYNOPSIS
        Terminates active Guacamole connection sessions

    .DESCRIPTION
        Forcefully disconnects active connection sessions on the Guacamole server.
        This is useful for terminating stuck or unauthorized sessions.

    .PARAMETER ConnectionIdentifier
        The identifier(s) of the active connection(s) to terminate (required)

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> Stop-GuacamoleActiveConnection -ConnectionIdentifier "123"

        Terminates the active connection with identifier "123"

    .EXAMPLE
        PS C:\> Get-GuacamoleActiveConnection | Where-Object { $_.username -eq "john" } | Stop-GuacamoleActiveConnection

        Terminates all active connections for user "john"

    .EXAMPLE
        PS C:\> Stop-GuacamoleActiveConnection -ConnectionIdentifier "123","456","789"

        Terminates multiple active connections

    .NOTES
        Author: Holger Voges
        Version: 1.0
        Date: 2025-01-16
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('identifier')]
        [string[]]$ConnectionIdentifier,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Begin {
        $ConnectionsToTerminate = @()
    }

    Process {
        $ConnectionsToTerminate += $ConnectionIdentifier
    }

    End {
        # Build the request body - array of connection identifiers to terminate
        $RequestBody = @()
        foreach ($ConnId in $ConnectionsToTerminate) {
            $RequestBody += @{
                op = "remove"
                path = "/$ConnId"
            }
        }

        $RequestBodyJson = $RequestBody | ConvertTo-Json -Depth 3

        $EndPoint = '{0}/api/session/data/{1}/activeConnections?token={2}' -f `
            $AuthToken.HostUrl, $AuthToken.Datasource, $AuthToken.AuthToken

        Write-Verbose "Endpoint: $Endpoint"
        Write-Verbose "Request body: $RequestBodyJson"

        if ($PSCmdlet.ShouldProcess("Active connection(s): $($ConnectionsToTerminate -join ', ')", "Terminate connection(s)")) {
            Try {
                $Response = Invoke-RestMethod -Uri $EndPoint -Method Patch `
                    -ContentType 'application/json' -Body $RequestBodyJson -ErrorAction Stop

                Write-Verbose "Successfully terminated $($ConnectionsToTerminate.Count) active connection(s)"
            }
            Catch {
                Write-Error "Failed to terminate active connection(s): $_"
                Throw $_
            }
        }
    }
}
