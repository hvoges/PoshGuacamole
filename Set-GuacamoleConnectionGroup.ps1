Function Set-GuacamoleConnectionGroup {
    <#
    .SYNOPSIS
        Updates the settings of a Guacamole Connection Group

    .DESCRIPTION
        Modifies an existing connection group's properties including name, parent, type, and attributes.

    .PARAMETER GroupID
        The identifier of the connection group to update (required)

    .PARAMETER GroupName
        The new name for the connection group

    .PARAMETER ParentGroupID
        The new parent connection group identifier

    .PARAMETER GroupType
        Type of connection group: ORGANIZATIONAL or BALANCING

    .PARAMETER MaxConnections
        Maximum simultaneous connections to all connections in this group

    .PARAMETER MaxConnectionsPerUser
        Maximum simultaneous connections per user in this group

    .PARAMETER EnableSessionAffinity
        Enable session affinity for load-balanced groups

    .PARAMETER Passthru
        Returns the updated connection group object

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> Set-GuacamoleConnectionGroup -GroupID "5" -GroupName "Updated Name"

        Updates the name of connection group ID "5"

    .EXAMPLE
        PS C:\> Set-GuacamoleConnectionGroup -GroupID "5" -MaxConnections 10 -MaxConnectionsPerUser 2 -Passthru

        Updates connection limits for group ID "5" and returns the updated object

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionGroup -GroupID "5" | Set-GuacamoleConnectionGroup -GroupType "BALANCING"

        Updates connection group "5" to be a load-balancing group using pipeline input

    .NOTES
        Author: Holger Voges
        Version: 1.0
        Date: 2025-01-16
    #>
    param(
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [Alias('identifier')]
        [string]$GroupID,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('name')]
        [string]$GroupName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('parentIdentifier')]
        [string]$ParentGroupID,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('ORGANIZATIONAL', 'BALANCING')]
        [string]$GroupType,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$MaxConnections,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$MaxConnectionsPerUser,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnableSessionAffinity,

        [switch]$Passthru,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {
        # First, get the current connection group to preserve existing values
        Try {
            $CurrentGroup = Get-GuacamoleConnectionGroup -GroupID $GroupID -AuthToken $AuthToken
        }
        Catch {
            Write-Error "Failed to retrieve connection group '$GroupID': $_"
            Throw $_
        }

        # Build attributes hashtable
        $GroupAttributes = [ordered]@{}

        # Preserve existing attributes or use new values
        if ( $PSBoundParameters.ContainsKey('MaxConnections') ) {
            $GroupAttributes."max-connections" = $MaxConnections.ToString()
        }
        elseif ( $CurrentGroup.attributes.'max-connections' ) {
            $GroupAttributes."max-connections" = $CurrentGroup.attributes.'max-connections'
        }

        if ( $PSBoundParameters.ContainsKey('MaxConnectionsPerUser') ) {
            $GroupAttributes."max-connections-per-user" = $MaxConnectionsPerUser.ToString()
        }
        elseif ( $CurrentGroup.attributes.'max-connections-per-user' ) {
            $GroupAttributes."max-connections-per-user" = $CurrentGroup.attributes.'max-connections-per-user'
        }

        if ( $PSBoundParameters.ContainsKey('EnableSessionAffinity') ) {
            $GroupAttributes."enable-session-affinity" = $EnableSessionAffinity.ToString().ToLower()
        }
        elseif ( $CurrentGroup.attributes.'enable-session-affinity' ) {
            $GroupAttributes."enable-session-affinity" = $CurrentGroup.attributes.'enable-session-affinity'
        }

        # Build the request body with current or updated values
        $GroupPropertiesDict = [ordered]@{
            identifier       = $GroupID
            name             = if ($GroupName) { $GroupName } else { $CurrentGroup.name }
            type             = if ($GroupType) { $GroupType } else { $CurrentGroup.type }
            parentIdentifier = if ($ParentGroupID) { $ParentGroupID } else { $CurrentGroup.parentIdentifier }
            attributes       = $GroupAttributes
        }

        $GroupProperties = $GroupPropertiesDict | ConvertTo-Json

        $EndPoint = '{0}/api/session/data/{1}/connectionGroups/{2}?token={3}' -f `
            $AuthToken.HostUrl, $AuthToken.Datasource, $GroupID, $AuthToken.AuthToken

        Write-Verbose "Endpoint: $Endpoint"
        Write-Verbose "Request body: $GroupProperties"

        Try {
            $Response = Invoke-RestMethod -Uri $EndPoint -Method Put `
                -ContentType 'application/json' -Body $GroupProperties

            Write-Verbose "Successfully updated connection group: $GroupID"

            If ( $Passthru ) {
                # Since PUT returns 204 No Content, retrieve the updated group
                Get-GuacamoleConnectionGroup -GroupID $GroupID -AuthToken $AuthToken
            }
        }
        Catch {
            Write-Error "Failed to update connection group '$GroupID': $_"
            Throw $_
        }
    }
}
