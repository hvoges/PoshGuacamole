Function Add-GuacamoleGroupMember {
<#
.SYNOPSIS
    Add Members to a Gucamole-Group
.DESCRIPTION
    Add Members to a Gucamole-Group
.EXAMPLE
    PS C:\> Get-GuacamoleConnection -ConnectionID PC12
    Returns the Connection-Settings for the Connection PC12
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-13
#>  
    param(
        [Parameter(Mandatory)]
        [string]$Groupname,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ValueFromPipeline)]
        [string]$Username,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

  process {
    $Command = @"
  [
    {
      "op": "add",
      "path": "/",
      "value": "$Groupname"
    }
  ]
"@
  
    $EndPoint = '{0}/api/session/data/{1}/users/{3}/userGroups?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Authtoken.Username
    Write-Verbose -Message $EndPoint
    Try {
      $Response = Invoke-RestMethod -Uri $EndPoint -Method Patch -ContentType 'application/json' -Body $Command -UseBasicParsing
    }
    Catch {
      Throw $_
    }
  }
}