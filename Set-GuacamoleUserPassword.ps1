Function Set-GuacamoleUserPassword {
    param(
        [Parameter(Mandatory)]
        $AuthToken,

        [string]$Username,

        [string]$OldPassword,
        
        [string]$NewPassword
    )

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