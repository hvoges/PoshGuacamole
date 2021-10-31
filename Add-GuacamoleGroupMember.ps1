Function Add-GuacamoleGroupMember {
    param(
        [Parameter(Mandatory)]
        $AuthToken,

        [string]$Groupname,

        [string]$Username        
    )

$Command = @"
[
  {
    "op": "add",
    "path": "/",
    "value": "$Groupname"
  }
]
"@
 
    $EndPoint = '{0}/api/session/data/{1}/users/{3}/userGroups?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$Username
    Write-Verbose -Message $EndPoint
    $Response = Invoke-WebRequest -Uri $EndPoint -Method Patch -ContentType 'application/json' -Body $Command
}