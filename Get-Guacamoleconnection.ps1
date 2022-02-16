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
    param(
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$ConnectionID,

        [Switch]$IncludeConnectionParameter,
        
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
            $ConnectionList = @( Get-GuacamoleAttributes -Object $WebResponse )
        }
        Else {
            $ConnectionList = Foreach ( $Property in $WebResponse.psobject.properties.Name ) {
                @( Get-GuacamoleAttributes -Object ( $WebResponse.( $Property )))
            }
        }
        If ( $IncludeConnectionParameter ) {
            Foreach ( $Connection in $ConnectionList )
            {
                $ConnectionParameter = Get-GuacamoleConnectionParameter -ConnectionID $Connection.identifier 
                Foreach ( $Parameter in $ConnectionParameter.psobject.Properties.Name )
                {
                    Add-Member -InputObject $Connection -MemberType NoteProperty -Name $Parameter -Value ($ConnectionParameter.$parameter)
                }
                $Connection
            }
        }
        Else {
            $ConnectionList
        }
    }
}