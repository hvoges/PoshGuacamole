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
      $AuthToken = $GuacAuthToken,

      # Returns the Disconnect-Response from the Web-Server 
      [Switch]$Passthru
    )

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
    Try {
      $Response = Invoke-RestMethod -Uri $EndPoint -Method Patch -Body $Command -UseBasicParsing
    }
    Catch {
      Throw $_
    }
    If ($Passthru)
    {
      $Response
    }
    if ( $Global:GuacAuthToken ) {
      Remove-Variable $Global:GuacAuthToken
    }
}