Function Get-GuacamoleConnectionHistory {
    <#
    .SYNOPSIS
        Returns the connection usage history for a specific Guacamole connection

    .DESCRIPTION
        Retrieves the historical usage records for a specific connection, showing when and by whom
        the connection was used.

    .PARAMETER ConnectionID
        The unique identifier of the connection (required)

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionHistory -ConnectionID "5"

        Returns the usage history for connection ID "5"

    .EXAMPLE
        PS C:\> Get-GuacamoleConnection -ConnectionName "WebServer" | Get-GuacamoleConnectionHistory

        Retrieves connection history using pipeline input

    .NOTES
        Author: Holger Voges
        Version: 1.0
        Date: 2025-01-16
    #>
    param(
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('identifier')]
        [string]$ConnectionID,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {
        $EndPoint = '{0}/api/session/data/{1}/connections/{3}/history?token={2}' -f `
            $AuthToken.HostUrl, $AuthToken.Datasource, $AuthToken.AuthToken, $ConnectionID

        Write-Verbose "Endpoint: $Endpoint"

        Try {
            Invoke-RestMethod -UseBasicParsing -Uri $EndPoint -ErrorAction Stop
        }
        Catch {
            Write-Error "Failed to retrieve connection history for connection '$ConnectionID': $_"
            Throw $_.Exception.Message
        }
    }
}
