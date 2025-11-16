Function Get-GuacamoleConnectionSharingProfile {
    <#
    .SYNOPSIS
        Returns sharing profiles associated with a specific Guacamole connection

    .DESCRIPTION
        Retrieves all sharing profiles that are associated with a specific connection.
        Sharing profiles allow connections to be shared with other users with specific permissions.

    .PARAMETER ConnectionID
        The identifier of the connection (required)

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionSharingProfile -ConnectionID "5"

        Returns all sharing profiles for connection ID "5"

    .EXAMPLE
        PS C:\> Get-GuacamoleConnection -ConnectionName "WebServer" | Get-GuacamoleConnectionSharingProfile

        Retrieves sharing profiles for the "WebServer" connection using pipeline input

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
        $EndPoint = '{0}/api/session/data/{1}/connections/{3}/sharingProfiles?token={2}' -f `
            $AuthToken.HostUrl, $AuthToken.Datasource, $AuthToken.AuthToken, $ConnectionID

        Write-Verbose "Endpoint: $Endpoint"

        Try {
            $WebResponse = Invoke-RestMethod -UseBasicParsing -Uri $EndPoint -ErrorAction Stop

            # Parse the response - sharing profiles are returned as a hashtable
            Foreach ( $Property in $WebResponse.psobject.properties.Name ) {
                $WebResponse.$Property
            }
        }
        Catch {
            Write-Error "Failed to retrieve sharing profiles for connection '$ConnectionID': $_"
            Throw $_.Exception.Message
        }
    }
}
