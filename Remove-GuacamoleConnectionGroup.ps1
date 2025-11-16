Function Remove-GuacamoleConnectionGroup {
    <#
    .SYNOPSIS
        Removes a Guacamole Connection Group

    .DESCRIPTION
        Deletes a connection group from the Guacamole server.
        Warning: This operation cannot be undone.

    .PARAMETER GroupID
        The identifier of the connection group to remove (required)

    .PARAMETER AuthToken
        The authentication token returned from Connect-Guacamole. Defaults to global $GuacAuthToken

    .EXAMPLE
        PS C:\> Remove-GuacamoleConnectionGroup -GroupID "5"

        Removes connection group with ID "5"

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionGroup -GroupID "5" | Remove-GuacamoleConnectionGroup

        Removes connection group "5" using pipeline input

    .EXAMPLE
        PS C:\> Get-GuacamoleConnectionGroup | Where-Object { $_.name -like "Test*" } | Remove-GuacamoleConnectionGroup

        Removes all connection groups with names starting with "Test"

    .NOTES
        Author: Holger Voges
        Version: 1.0
        Date: 2025-01-16
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [Alias('identifier')]
        [string]$GroupID,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {
        $EndPoint = '{0}/api/session/data/{1}/connectionGroups/{2}?token={3}' -f `
            $AuthToken.HostUrl, $AuthToken.Datasource, $GroupID, $AuthToken.AuthToken

        Write-Verbose "Endpoint: $Endpoint"

        if ($PSCmdlet.ShouldProcess("Connection Group ID: $GroupID", "Remove connection group")) {
            Try {
                $Response = Invoke-RestMethod -Uri $EndPoint -Method Delete
                Write-Verbose "Successfully removed connection group: $GroupID"
            }
            Catch {
                Write-Error "Failed to remove connection group '$GroupID': $_"
                Throw $_
            }
        }
    }
}
