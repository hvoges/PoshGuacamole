Function Set-GuacamoleConnection {
    <#
    .SYNOPSIS
        Updates a Guacamole connection's properties

    .DESCRIPTION
        Generic function to update a Guacamole connection. This function allows updating
        basic connection properties like name, parent group, and protocol-specific parameters.

    .PARAMETER ConnectionID
        The identifier of the connection to update (required)

    .PARAMETER ConnectionName
        The new name for the connection

    .PARAMETER ParentGroupID
        The new parent connection group identifier

    .PARAMETER Parameters
        Hashtable of connection parameters (protocol-specific)

    .PARAMETER Attributes
        Hashtable of connection attributes

    .PARAMETER Passthru
        Returns the updated connection object

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> Set-GuacamoleConnection -ConnectionID "5" -ConnectionName "Updated Server"

        Updates the name of connection ID "5"

    .EXAMPLE
        PS C:\> $params = @{ hostname = "newserver.example.com"; port = "3389" }
        PS C:\> Set-GuacamoleConnection -ConnectionID "5" -Parameters $params -Passthru

        Updates connection parameters and returns the updated object

    .EXAMPLE
        PS C:\> Get-GuacamoleConnection -ConnectionID "5" | Set-GuacamoleConnection -ParentGroupID "10"

        Moves connection "5" to parent group "10" using pipeline input

    .NOTES
        Author: Holger Voges
        Version: 1.0
        Date: 2025-01-16
    #>
    param(
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [Alias('identifier')]
        [string]$ConnectionID,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('name')]
        [string]$ConnectionName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('parentIdentifier')]
        [string]$ParentGroupID,

        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]$Parameters,

        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]$Attributes,

        [switch]$Passthru,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {
        # First, get the current connection to preserve existing values
        Try {
            $CurrentConnection = Get-GuacamoleConnection -ConnectionID $ConnectionID -AuthToken $AuthToken
        }
        Catch {
            Write-Error "Failed to retrieve connection '$ConnectionID': $_"
            Throw $_
        }

        # Build the request body with current or updated values
        $ConnectionHashTable = [ordered]@{
            identifier       = $ConnectionID
            name             = if ($ConnectionName) { $ConnectionName } else { $CurrentConnection.name }
            protocol         = $CurrentConnection.protocol
            parentIdentifier = if ($ParentGroupID) { $ParentGroupID } else { $CurrentConnection.parentIdentifier }
        }

        # Handle parameters
        if ($Parameters) {
            $ConnectionHashTable.parameters = $Parameters
        }
        elseif ($CurrentConnection.parameters) {
            $ConnectionHashTable.parameters = $CurrentConnection.parameters
        }

        # Handle attributes
        if ($Attributes) {
            $ConnectionHashTable.attributes = $Attributes
        }
        elseif ($CurrentConnection.attributes) {
            $ConnectionHashTable.attributes = $CurrentConnection.attributes
        }

        $RequestBody = $ConnectionHashTable | ConvertTo-Json -Depth 10

        $EndPoint = '{0}/api/session/data/{1}/connections/{2}?token={3}' -f `
            $AuthToken.HostUrl, $AuthToken.Datasource, $ConnectionID, $AuthToken.AuthToken

        Write-Verbose "Endpoint: $Endpoint"
        Write-Verbose "Request body: $RequestBody"

        Try {
            $Response = Invoke-RestMethod -Uri $EndPoint -Method Put `
                -ContentType 'application/json' -Body $RequestBody -ErrorAction Stop

            Write-Verbose "Successfully updated connection: $ConnectionID"

            If ( $Passthru ) {
                # Retrieve the updated connection
                Get-GuacamoleConnection -ConnectionID $ConnectionID -AuthToken $AuthToken
            }
        }
        Catch {
            Write-Error "Failed to update connection '$ConnectionID': $_"
            Throw $_
        }
    }
}
