Function New-GuacamoleConnectionGroup {
    <#
    .SYNOPSIS
        Creates a new Guacamole Connection Group

    .DESCRIPTION
        Creates a new connection group for organizing and managing Guacamole connections.
        Connection groups can be used for organizational purposes or load balancing.

    .PARAMETER GroupName
        The name of the connection group to create

    .PARAMETER ParentGroupID
        The parent connection group identifier. Defaults to "ROOT" for top-level groups.

    .PARAMETER GroupType
        Type of connection group: ORGANIZATIONAL (for organization) or BALANCING (for load balancing).
        Defaults to ORGANIZATIONAL.

    .PARAMETER MaxConnections
        Maximum simultaneous connections to all connections in this group

    .PARAMETER MaxConnectionsPerUser
        Maximum simultaneous connections per user in this group

    .PARAMETER EnableSessionAffinity
        Enable session affinity for load-balanced groups (maintains user session to same connection)

    .PARAMETER Passthru
        Returns the created connection group object

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> New-GuacamoleConnectionGroup -GroupName "Remote Servers"

        Creates a new top-level organizational connection group named "Remote Servers"

    .EXAMPLE
        PS C:\> New-GuacamoleConnectionGroup -GroupName "Lab Servers" -ParentGroupID "1" -GroupType "BALANCING" -MaxConnections 5 -Passthru

        Creates a load-balancing connection group under parent group 1 with a maximum of 5 connections

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionGroup -GroupName "Production" | New-GuacamoleConnectionGroup -GroupName "Web Servers"

        Creates a new connection group "Web Servers" as a child of the "Production" group using pipeline input

    .NOTES
        Author: Holger Voges
        Version: 1.0
    #>
    [CmdletBinding()]
    param(
        # The name of the connection group
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [Alias('name')]
        [string]$GroupName,

        # The parent connection group identifier (default: ROOT for top-level)
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('parentIdentifier','identifier')]
        [string]$ParentGroupID = "ROOT",

        # Type of connection group: ORGANIZATIONAL or BALANCING
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('ORGANIZATIONAL', 'BALANCING')]
        [string]$GroupType = 'ORGANIZATIONAL',

        # Maximum simultaneous connections to all connections in this group
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$MaxConnections,

        # Maximum simultaneous connections per user in this group
        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$MaxConnectionsPerUser,

        # Enable session affinity for load-balanced groups
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$EnableSessionAffinity,

        # Return the created connection group
        [switch]$Passthru,

        # Authentication token (hidden parameter)
        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {
        # Build attributes hashtable
        $GroupAttributes = [ordered]@{}

        If ($PSBoundParameters.ContainsKey('MaxConnections')) {
            $GroupAttributes."max-connections" = $MaxConnections.ToString()
        }

        If ($PSBoundParameters.ContainsKey('MaxConnectionsPerUser')) {
            $GroupAttributes."max-connections-per-user" = $MaxConnectionsPerUser.ToString()
        }

        If ($PSBoundParameters.ContainsKey('EnableSessionAffinity')) {
            $GroupAttributes."enable-session-affinity" = $EnableSessionAffinity.ToString().ToLower()
        }

        # Build connection group hashtable
        $GroupHashTable = [ordered]@{
            parentIdentifier = $ParentGroupID
            name             = $GroupName
            type             = $GroupType
            attributes       = $GroupAttributes
        }

        # Convert to JSON and send to API
        $RequestBody = $GroupHashTable | ConvertTo-Json

        $EndPoint = '{0}/api/session/data/{1}/connectionGroups?token={2}' -f `
            $AuthToken.HostUrl, $AuthToken.Datasource, $AuthToken.AuthToken

        Write-Verbose "Creating connection group at endpoint: $EndPoint"
        Write-Verbose "Request body: $RequestBody"

        Try {
            $Response = Invoke-RestMethod -Uri $EndPoint -Method Post `
                -ContentType 'application/json' -Body $RequestBody

            Write-Verbose "Successfully created connection group: $GroupName"

            If ($Passthru) {
                $Response
            }
        }
        Catch {
            Write-Error "Failed to create connection group '$GroupName': $_"
            Throw $_
        }
    }
}
