Function New-GuacamoleSshConnection {
    <#
    .SYNOPSIS
        Creates a new Guacamole SSH connection

    .DESCRIPTION
        Creates a new SSH (Secure Shell) connection in Guacamole with the specified parameters.

    .PARAMETER ConnectionName
        The display name for the SSH connection (required)

    .PARAMETER Hostname
        The hostname or IP address of the SSH server (required)

    .PARAMETER Port
        The SSH server port (default: 22)

    .PARAMETER Username
        The SSH username for authentication

    .PARAMETER Password
        The SSH password for authentication

    .PARAMETER PrivateKey
        The private key for SSH key-based authentication

    .PARAMETER Passphrase
        The passphrase for the private key

    .PARAMETER ParentGroupID
        The parent connection group identifier (default: "ROOT")

    .PARAMETER MaxConnections
        Maximum number of concurrent connections

    .PARAMETER MaxConnectionsPerUser
        Maximum number of concurrent connections per user

    .PARAMETER ColorScheme
        Color scheme for the SSH terminal (black-white, gray-black, green-black, white-black, etc.)

    .PARAMETER FontSize
        Font size for the terminal (8-24)

    .PARAMETER Passthru
        Returns the created connection object

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> New-GuacamoleSshConnection -ConnectionName "Ubuntu Server" -Hostname "ubuntu.example.com" -Username "admin" -Password "secret"

        Creates a new SSH connection to Ubuntu Server

    .EXAMPLE
        PS C:\> New-GuacamoleSshConnection -ConnectionName "Web Server" -Hostname "192.168.1.50" -Port 2222 -Username "root" -PrivateKey "..." -Passthru

        Creates a new SSH connection with key-based auth and custom port

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
        [int]$Port = 22,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Username,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Password,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$PrivateKey,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Passphrase,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('parentIdentifier')]
        [string]$ParentGroupID = "ROOT",

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$MaxConnections,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$MaxConnectionsPerUser,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('black-white', 'gray-black', 'green-black', 'white-black')]
        [string]$ColorScheme,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(8, 24)]
        [int]$FontSize,

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
        if ($PrivateKey) { $ConnectionParameter.'private-key' = $PrivateKey }
        if ($Passphrase) { $ConnectionParameter.passphrase = $Passphrase }
        if ($ColorScheme) { $ConnectionParameter.'color-scheme' = $ColorScheme }
        if ($FontSize) { $ConnectionParameter.'font-size' = $FontSize.ToString() }

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
            protocol         = "ssh"
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

            Write-Verbose "Successfully created SSH connection: $ConnectionName"

            If ($Passthru) {
                $Response
            }
        }
        Catch {
            Write-Error "Failed to create SSH connection '$ConnectionName': $_"
            Throw $_
        }
    }
}
