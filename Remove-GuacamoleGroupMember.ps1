Function Remove-GuacamoleGroupMember {
<#
.SYNOPSIS
    Removes a User from a group
.DESCRIPTION
    Removes a User from a Group. To Remove serveral Users from a Group, use the Pipeline.
.EXAMPLE
    PS C:\> Remove-GuacamoleGroupMember -GroupName 
    Returns the Connection-Settings for the Connection PC12
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-13
#>  
    param(
        [Parameter(Mandatory)]
        $AuthToken = $GuacAuthToken,

        [string]$Groupname,

        [string]$Username        
    )

$Command = @"
[
  {
    "op": "remove",
    "path": "/",
    "value": "$Groupname"
  }
]
"@
 
    $EndPoint = '{0}/api/session/data/{1}/users/{3}/userGroups?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username
    Write-Verbose -Message $EndPoint
    Try {
        $Response = Invoke-RestMethod -Uri $EndPoint -Method Patch -ContentType 'application/json' -Body $Command
    }
    Catch {
        Throw $_
    }
}