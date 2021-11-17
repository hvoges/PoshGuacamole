Function Disconnect-Guacamole {
<#
.SYNOPSIS
  Disconnect your Guacamole-Session
.DESCRIPTION
  Disconnects from Guacamole and removes the global Authentication-Token
.EXAMPLE
  PS C:\> Disconnect-Gua
  Explanation of what the example does
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-13
#>
    param(
        
      # The authentication-Token, when a local Token was used  
      $AuthToken,

      # Returns the Disconnect-Response from the Web-Server 
      [Switch]$Passthru
    )

    If (! $AuthToken)
    {
      $AuthToken = $Global:GuacAuthToken
    }

    $EndPoint = '{0}/api/session/data/{1}/users/{3}/permissions?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$AuthToken.username

    $Command = @"
[
  {
    "op": "remove",
    "path": "/connectionPermissions/$ConnectionId",
    "value": "READ"
  }
]
"@

    Write-Verbose $Endpoint
    $Response = Invoke-WebRequest -Uri $EndPoint -Method Patch -Body $Command | ConvertFrom-Json
    If ($Passthru)
    {
      $Response
    }
    if ( $Global:GuacAuthToken ) {
      Remove-Variable $Global:GuacAuthToken
    }
}