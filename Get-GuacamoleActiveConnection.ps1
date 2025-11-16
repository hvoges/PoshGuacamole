Function Get-GuacamoleActiveConnection {
    <#
    .SYNOPSIS
        Returns currently active Guacamole connection sessions

    .DESCRIPTION
        Retrieves a list of all currently active connection sessions on the Guacamole server.
        Shows which connections are actively being used and by whom.

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> Get-GuacamoleActiveConnection

        Returns all currently active connection sessions

    .EXAMPLE
        PS C:\> Get-GuacamoleActiveConnection | Where-Object { $_.username -eq "john" }

        Returns all active connections for user "john"

    .NOTES
        Author: Holger Voges
        Version: 1.0
        Date: 2025-01-16
    #>
    param(
        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {
        $EndPoint = '{0}/api/session/data/{1}/activeConnections?token={2}' -f `
            $AuthToken.HostUrl, $AuthToken.Datasource, $AuthToken.AuthToken

        Write-Verbose "Endpoint: $Endpoint"

        Try {
            $WebResponse = Invoke-RestMethod -UseBasicParsing -Uri $EndPoint -ErrorAction Stop

            # Parse the response - active connections are returned as a hashtable
            Foreach ( $Property in $WebResponse.psobject.properties.Name ) {
                $WebResponse.$Property
            }
        }
        Catch {
            Write-Error "Failed to retrieve active connections: $_"
            Throw $_.Exception.Message
        }
    }
}
