Function Set-GuacamoleUserPassword {
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
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$Username,

        [string]$OldPassword,
        
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$NewPassword,

        $AuthToke = $GuacAuthToken
    )

    Process {    
        $EndPoint = '{0}/api/session/data/{1}/users/{3}/password?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username

        $Command = @"
    {
        "oldPassword": "$OldPassword",
        "newPassword": "$NewPassword"
    }
"@

        Write-Verbose $Endpoint
        $Response = Invoke-WebRequest -Uri $EndPoint -Method Put -Body $Command | ConvertFrom-Json    
    }
}