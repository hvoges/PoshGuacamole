Function Get-GuacamoleUser {
<#
.SYNOPSIS
    Returns an individual or all Guacamole-Users
.DESCRIPTION
    Returns an individual or all Guacamole-Users
.EXAMPLE
    PS C:\> Get-GuacamoleUser 
    Returns all Guacamole-Users
.NOTES
    Author: Holger Voges
    Version: 1.2
    Date: 2022-05-22
#>    
    [CmdletBinding(DefaultParameterSetName='UserName')]
    param(        
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParametersetName = 'Username')]
        [String]$Username,

        # Filter for Usernames. The filter takes a regular expression as input.
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParametersetName = 'Filter')]
        [String]$Filter,

        # List all Attributes as Object Properties, even empty ones. If you use this parameter, you 
        # may break the Pipeline-Functionality.
        [Switch]$ShowEmptyAttributes,

        # Returns the Raw JSON-String
        [Switch]$Raw,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Begin {
        $EndPoint = '{0}/api/session/data/{1}/users?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken
        Write-Verbose $Endpoint
        Try {
            $WebResponse = Invoke-WebRequest -UseBasicParsing -Uri $EndPoint -ErrorAction Stop
        }
        Catch {
            Throw $_.Exception.Message
        }
        $UserList = $WebResponse | ConvertFrom-Json         
    }

    Process {
        # return only the json-answer
        if ( $Raw ) { 
            $WebResponse.Content
         }
        elseif ( $Username ) {
            $User = $UserList.$Username
            Get-GuacamoleAttributes -Object $User -ShowEmptyAttributes:$ShowEmptyAttributes
        }
        elseif ( $PSCmdlet.ParameterSetName -eq 'Filter' ) {
            # Because all Users are single Properties of Object UserList, filter all Properties which match $filter
            $Usernames = $UserList.psobject.properties.name | 
                Where-Object { $_ -match $Filter }
            $FilteredUserList = $UserList | Select-Object -Property $Usernames
            Foreach ( $User in $Usernames )
            {
                Get-GuacamoleAttributes -Object $UserList.$user -ShowEmptyAttributes:$ShowEmptyAttributes
            }
        }
        Else {
            Foreach ( $User in $UserList.psobject.properties.Name ) {
                Get-GuacamoleAttributes -Object $UserList.$User -ShowEmptyAttributes:$ShowEmptyAttributes
            }        
        }
    }
}