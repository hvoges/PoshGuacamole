Function New-GuacamoleVncConnection {
    <#
    .SYNOPSIS
        Creates a new Guacamole VNC connection

    .DESCRIPTION
        Creates a new VNC (Virtual Network Computing) connection in Guacamole with the specified parameters.

    .PARAMETER ConnectionName
        The display name for the VNC connection (required)

    .PARAMETER Hostname
        The hostname or IP address of the VNC server (required)

    .PARAMETER Port
        The VNC server port (default: 5900)

    .PARAMETER Username
        The VNC username for authentication

    .PARAMETER Password
        The VNC password for authentication

    .PARAMETER ParentGroupID
        The parent connection group identifier (default: "ROOT")

    .PARAMETER MaxConnections
        Maximum number of concurrent connections

    .PARAMETER MaxConnectionsPerUser
        Maximum number of concurrent connections per user

    .PARAMETER ColorDepth
        Color depth for the VNC connection (8, 16, 24, or 32)

    .PARAMETER ReadOnly
        Set to true for read-only access

    .PARAMETER Passthru
        Returns the created connection object

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> New-GuacamoleVncConnection -ConnectionName "Ubuntu Desktop" -Hostname "192.168.1.100" -Password "secret"

        Creates a new VNC connection to Ubuntu Desktop

    .EXAMPLE
        PS C:\> New-GuacamoleVncConnection -ConnectionName "CentOS Server" -Hostname "centos.example.com" -Port 5901 -Username "admin" -Password "pass" -Passthru

        Creates a new VNC connection with custom port and returns the created object

    .NOTES
        Author: Holger Voges
        Version: 1.0
        Date: 2025-01-16
    #>
    param(
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [Alias('name')]
        [string]$ConnectionName,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string]$Hostname,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$Port = 5900,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Username,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Password,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('parentIdentifier')]
        [string]$ParentGroupID = "ROOT",

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$MaxConnections,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$MaxConnectionsPerUser,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('8', '16', '24', '32')]
        [string]$ColorDepth,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$ReadOnly,

        [switch]$Passthru,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {
        # Build connection parameters
        $ConnectionParameter = [ordered]@{
            hostname = $Hostname
            port     = $Port.ToString()
        }

        # Add optional parameters
        if ($Username) { $ConnectionParameter.username = $Username }
        if ($Password) { $ConnectionParameter.password = $Password }
        if ($ColorDepth) { $ConnectionParameter.'color-depth' = $ColorDepth }
        if ($PSBoundParameters.ContainsKey('ReadOnly')) {
            $ConnectionParameter.'read-only' = $ReadOnly.ToString().ToLower()
        }

        # Build connection attributes
        $ConnectionAttribute = [ordered]@{}
        if ($MaxConnections) {
            $ConnectionAttribute.'max-connections' = $MaxConnections.ToString()
        }
        if ($MaxConnectionsPerUser) {
            $ConnectionAttribute.'max-connections-per-user' = $MaxConnectionsPerUser.ToString()
        }

        # Build the connection object
        $ConnectionHashTable = [ordered]@{
            parentIdentifier = $ParentGroupID
            name             = $ConnectionName
            protocol         = "vnc"
            parameters       = $ConnectionParameter
            attributes       = $ConnectionAttribute
        }

        $RequestBody = $ConnectionHashTable | ConvertTo-Json -Depth 10

        $EndPoint = '{0}/api/session/data/{1}/connections?token={2}' -f `
            $AuthToken.HostUrl, $AuthToken.Datasource, $AuthToken.AuthToken

        Write-Verbose "Endpoint: $EndPoint"
        Write-Verbose "Request body: $RequestBody"

        Try {
            $Response = Invoke-RestMethod -Uri $EndPoint -Method Post `
                -ContentType 'application/json' -Body $RequestBody -ErrorAction Stop

            Write-Verbose "Successfully created VNC connection: $ConnectionName"

            If ($Passthru) {
                $Response
            }
        }
        Catch {
            Write-Error "Failed to create VNC connection '$ConnectionName': $_"
            Throw $_
        }
    }
}
