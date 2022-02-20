Function Get-GuacamoleConnection {
<#
.SYNOPSIS
    Returns an individual or all Guacamole-Connections
.DESCRIPTION
    Returns an individual or all Guacamole-Connections
.EXAMPLE
    PS C:\> Get-GuacamoleConnection -ConnectionID PC12
    Returns the Connection-Settings for the Connection PC12
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-13
#>
    [CmdletBinding(DefaultParameterSetName='All')]
    param(
        # The Connection-ID is a unique numerical identifier. You can either
        # filter for the Connection-ID or a Connection-Name
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='ByID')]
        [string]$ConnectionID,

        # The Name of the connection. You can either filter by name or by
        # Connection-ID 
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='ByName')]
        [string[]]$ConnectionName,

        # Filter for the Protocol-Type
        [ValidateSet('rdp','vnc','ssh','telnet','kubernetes')]
        [string[]]$Protocol = @('rdp,vnc','ssh','telnet','kubernetes'),
        
        # List all Attributes as Object Properties, even empty ones. If you use this parameter, you 
        # may break the Pipeline-Functionality.
        [Switch]$ShowEmptyAttributes,

        # Adds the Connection-Parameter to the Output
        [Switch]$IncludeConnectionParameter,
        
        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {    
        if ( $ConnectionID ) {
            $EndPoint = '{0}/api/session/data/{1}/connections/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$ConnectionID
        } 
        else {
            $EndPoint = '{0}/api/session/data/{1}/connections?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken
        }

        Write-Verbose $Endpoint
        Try {
            $WebResponse = Invoke-RestMethod -UseBasicParsing -Uri $EndPoint
        }
        Catch {
            Throw $_
        }

        If ( $WebResponse.Name ) {
            $ConnectionList = @( Get-GuacamoleAttributes -Object $WebResponse -ShowEmptyAttributes:$ShowEmptyAttributes | 
                Where-Object -FilterScript { $_.protocol -in $protocol } )
            if ( $IncludeConnectionParameter) {
                $ConnectionParameter = Get-GuacamoleConnectionParameter -ConnectionID $ConnectionList.identifier 
                $ConnectionList | Add-Member -MemberType NoteProperty -Name ConnectionParameter -Value $ConnectionParameter
            }
        }
        Else {
            $ConnectionList = Foreach ( $Property in $WebResponse.psobject.properties.Name ) {
                $Connection = @( Get-GuacamoleAttributes -Object ( $WebResponse.( $Property )) -ShowEmptyAttributes:$ShowEmptyAttributes | 
                    Where-Object -FilterScript { $_.protocol -in $protocol }  )
                if ( $IncludeConnectionParameter ) {
                    $ConnectionParameter = Get-GuacamoleConnectionParameter -ConnectionID $Connection.identifier 
                    $Connection | Add-Member -MemberType NoteProperty -Name ConnectionParameter -Value $ConnectionParameter
                }
                $Connection
            }
        }
        If ( $ConnectionName ) {
            $ConnectionList | Where-Object -FilterScript { $_.name -in $ConnectionName }
        }
        Else {
            $ConnectionList
        }
    }
}