Function Add-GuacamoleUserConnection {
<#
.SYNOPSIS
    Adds a connection to a user. 
.DESCRIPTION
    Adds a connection to user. Can be called via pipeline. 
.EXAMPLE
    PS C:\> Add-GuacamoleUserConnection -Username DemoUser -ConnectionID 43
    Adds the Connection with ID 43 to Demouser
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2022-02-16
#>  
    param(
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$Username,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='ByID')]
        [string]$ConnectionID,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName
                   ParameterSetName='ByName')]
        [string]$ConnectionName,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    Process {
        $EndPoint = '{0}/api/session/data/{1}/users/{3}/permissions?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username

        $Command = @"
    [
    {
        "op": "add",
        "path": "/connectionPermissions/$ConnectionId",
        "value": "READ"
    }
    ]
"@

        Write-Verbose $Endpoint
        Try {
            $Response = Invoke-RestMethod -Uri $EndPoint -Method Patch -Body $Command -UseBasicParsing -ErrorAction Stop
        }
        Catch {
            Throw $_
        }
    }
}