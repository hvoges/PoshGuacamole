Function Get-GuacamoleConnectionGroup {
    <#
    .SYNOPSIS
        Returns Guacamole Connection Groups

    .DESCRIPTION
        Returns an individual connection group or all connection groups from a Guacamole server.
        Can return details of a specific connection group by ID or name.

    .PARAMETER GroupID
        The identifier of a specific connection group to retrieve

    .PARAMETER ShowEmptyAttributes
        List all attributes as object properties, even empty ones.
        Note: Using this parameter may break pipeline functionality.

    .PARAMETER Raw
        Returns the raw JSON string instead of a PowerShell object

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionGroup

        Returns all connection groups

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionGroup -GroupID "5"

        Returns details of connection group with ID "5"

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionGroup -Raw

        Returns all connection groups as raw JSON

    .NOTES
        Author: Holger Voges
        Version: 1.0
        Date: 2025-01-16
    #>
    param(
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('identifier')]
        [string]$GroupID,

        # List all Attributes as Object Properties, even empty ones. If you use this parameter, you
        # may break the Pipeline-Functionality.
        [Switch]$ShowEmptyAttributes,

        # Returns the Raw JSON-String
        [Switch]$Raw,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {
        if ( $GroupID ) {
            $EndPoint = '{0}/api/session/data/{1}/connectionGroups/{3}?token={2}' -f `
                $AuthToken.HostUrl, $AuthToken.Datasource, $AuthToken.AuthToken, $GroupID
        }
        Else {
            $EndPoint = '{0}/api/session/data/{1}/connectionGroups?token={2}' -f `
                $AuthToken.HostUrl, $AuthToken.Datasource, $AuthToken.AuthToken
        }

        Write-Verbose "Endpoint: $Endpoint"

        Try {
            $WebResponse = Invoke-WebRequest -UseBasicParsing -Uri $EndPoint -ErrorAction Stop
            $GroupList = $WebResponse.Content | ConvertFrom-Json
        }
        Catch {
            Write-Error "Failed to retrieve connection group(s): $_"
            Throw $_.Exception.Message
        }

        if ( $Raw ) {
            $WebResponse.Content
        }
        elseif ( $GroupList.identifier ) {
            # Single group returned
            Get-GuacamoleAttributes -Object $GroupList -ShowEmptyAttributes:$ShowEmptyAttributes
        }
        Else {
            # Multiple groups returned
            Foreach ( $Property in $GroupList.psobject.properties.Name ) {
                Get-GuacamoleAttributes -Object $GroupList.$Property -ShowEmptyAttributes:$ShowEmptyAttributes
            }
        }
    }
}
