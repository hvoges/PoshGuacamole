Function Get-GuacamoleSharingProfile {
    <#
    .SYNOPSIS
        Returns Guacamole sharing profiles

    .DESCRIPTION
        Retrieves all sharing profiles or a specific sharing profile from the Guacamole server.
        Sharing profiles allow connections to be shared with other users.

    .PARAMETER ProfileID
        The identifier of a specific sharing profile to retrieve

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> Get-GuacamoleSharingProfile

        Returns all sharing profiles

    .EXAMPLE
        PS C:\> Get-GuacamoleSharingProfile -ProfileID "5"

        Returns details of sharing profile with ID "5"

    .NOTES
        Author: Holger Voges
        Version: 1.0
        Date: 2025-01-16
    #>
    param(
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('identifier')]
        [string]$ProfileID,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {
        if ( $ProfileID ) {
            $EndPoint = '{0}/api/session/data/{1}/sharingProfiles/{3}?token={2}' -f `
                $AuthToken.HostUrl, $AuthToken.Datasource, $AuthToken.AuthToken, $ProfileID
        }
        Else {
            $EndPoint = '{0}/api/session/data/{1}/sharingProfiles?token={2}' -f `
                $AuthToken.HostUrl, $AuthToken.Datasource, $AuthToken.AuthToken
        }

        Write-Verbose "Endpoint: $Endpoint"

        Try {
            $WebResponse = Invoke-RestMethod -UseBasicParsing -Uri $EndPoint -ErrorAction Stop

            # Check if single profile or multiple
            if ( $WebResponse.identifier ) {
                # Single profile returned
                $WebResponse
            }
            Else {
                # Multiple profiles returned
                Foreach ( $Property in $WebResponse.psobject.properties.Name ) {
                    $WebResponse.$Property
                }
            }
        }
        Catch {
            Write-Error "Failed to retrieve sharing profile(s): $_"
            Throw $_.Exception.Message
        }
    }
}
