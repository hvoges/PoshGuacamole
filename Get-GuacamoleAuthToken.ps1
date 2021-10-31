Function  Get-GuacamoleAuthToken 
{
param(
    [string]$Username = 'guacadmin',
    
    [Parameter(mandatory)]
    [string]$Password, 

    [Parameter(mandatory)]
    [String]$HostUrl
)

    $EndPoint = '{0}/api/tokens' -f $HostUrl
    $ApiResponse = (Invoke-WebRequest -Uri $EndPoint -Method Post -Body @{"username"="$Username";"password"="$Password"}).Content 
    $AuthToken = $ApiResponse | ConvertFrom-Json 
    $AuthToken | Add-Member -Name HostUrl -Value $HostUrl -MemberType NoteProperty
    $AuthToken | Add-Member -Name JsonToken -Value $ApiResponse -MemberType NoteProperty
    $AuthToken
}