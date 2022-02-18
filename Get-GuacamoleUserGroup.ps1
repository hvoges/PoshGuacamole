Function Get-GuacamoleUserGroup {
<#
.SYNOPSIS
    Returns Guacamole Groups 
.DESCRIPTION
    Returns an individual or all Guacamole-Users
.EXAMPLE
    PS C:\> Get-GuacamoleUserGroup
    Returns all User-Groups
.NOTES
    Author: Holger Voges
    Version: 1.1
    Date: 2022-02-16
#>    
    param(
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$GroupName,

        # List all Attributes as Object Properties, even empty ones. If you use this parameter, you 
        # may break the Pipeline-Functionality.
        [Switch]$ShowEmptyAttributes,

        # Returns the Raw JSON-String
        [Switch]$Raw,

        $AuthToken = $GuacAuthToken
    )

    Process {
        if ( $GroupName ) {
            $EndPoint = '{0}/api/session/data/{1}/userGroups/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$GroupName
        }
        Else {
            $EndPoint = '{0}/api/session/data/{1}/userGroups?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken
        }

        Write-Verbose $Endpoint
        Try {
            $WebResponse = Invoke-WebRequest -UseBasicParsing -Uri $EndPoint -ErrorAction Stop
            $GroupList = $WebResponse.Content | ConvertFrom-Json
        }
        Catch {
            Throw $_.Exception.Message
        }

        if ( $Raw ) { 
            $WebResponse.Content
         }
        elseif ( $GroupList.identifier ) {
            Get-GuacamoleAttributes -Object $GroupList -ShowEmptyAttributes:$ShowEmptyAttributes
        }
        Else {
            Foreach ( $Property in $GroupList.psobject.properties.Name ) {
                Get-GuacamoleAttributes -Object $GroupList.$Property -ShowEmptyAttributes:$ShowEmptyAttributes
            }        
        }

    }
}