Function Get-GuacamoleConnectionGroupTree {
    <#
    .SYNOPSIS
        Returns Guacamole Connection Group Tree

    .DESCRIPTION
        Returns the connection group tree structure, including nested groups and connections.
        Can return the entire tree from ROOT or a specific connection group's subtree.

    .PARAMETER GroupID
        The identifier of a specific connection group to retrieve the tree for.
        Defaults to "ROOT" to get the entire tree.

    .PARAMETER Permission
        Optional permission filter to apply when retrieving the tree

    .PARAMETER ShowEmptyAttributes
        List all attributes as object properties, even empty ones.
        Note: Using this parameter may break pipeline functionality.

    .PARAMETER Raw
        Returns the raw JSON string instead of a PowerShell object

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionGroupTree

        Returns the complete connection group tree from ROOT

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionGroupTree -GroupID "5"

        Returns the connection group tree for group ID "5" and its children

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionGroupTree -GroupID "ROOT" -Permission "READ"

        Returns the ROOT tree filtered by READ permission

    .NOTES
        Author: Holger Voges
        Version: 1.0
        Date: 2025-01-16
    #>
    param(
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('identifier')]
        [string]$GroupID = "ROOT",

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Permission,

        # List all Attributes as Object Properties, even empty ones. If you use this parameter, you
        # may break the Pipeline-Functionality.
        [Switch]$ShowEmptyAttributes,

        # Returns the Raw JSON-String
        [Switch]$Raw,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {
        # Build the endpoint URL
        $EndPoint = '{0}/api/session/data/{1}/connectionGroups/{2}/tree?token={3}' -f `
            $AuthToken.HostUrl, $AuthToken.Datasource, $GroupID, $AuthToken.AuthToken

        # Add optional permission parameter
        if ( $Permission ) {
            $EndPoint += "&permission=$Permission"
        }

        Write-Verbose "Endpoint: $Endpoint"

        Try {
            $WebResponse = Invoke-WebRequest -UseBasicParsing -Uri $EndPoint -ErrorAction Stop
            $TreeData = $WebResponse.Content | ConvertFrom-Json
        }
        Catch {
            Write-Error "Failed to retrieve connection group tree: $_"
            Throw $_.Exception.Message
        }

        if ( $Raw ) {
            $WebResponse.Content
        }
        else {
            Get-GuacamoleAttributes -Object $TreeData -ShowEmptyAttributes:$ShowEmptyAttributes
        }
    }
}
