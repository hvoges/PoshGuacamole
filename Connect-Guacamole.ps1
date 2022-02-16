Function  Connect-Guacamole 
{
<#
.SYNOPSIS
    Open a Connection to your Guacamole-Server 
.DESCRIPTION
    This Cmdlet gets an Authentication-Token for the Guacamole Web-Service. You have to initialize a connection with this cmdlet
    before you can control your server. 
.EXAMPLE
    PS C:\> Connect-Guacamole -HostUrl https://myGuacamole.io -Credential Guacadmin
    Connects to your Server and stores an Authentication-Token for further use
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-13
#>
param(
    # The URL to your Server    
    [Parameter(mandatory)]
    [ValidateScript({ 
        if ( $_ -notmatch '^(https?:\/\/)?([\da-z\.-]+\.[a-z\.]{2,6}|[\d\.]+)([\/:?=&#]{1}[\da-z\.-]+)*[\/\?]?$' ) {  
            Throw "Invalid URL"}
        $true }
    )]
    [String]$HostUrl,

    # The Credential to a User with administrative Permissions
    [Parameter(mandatory)]
    [PSCredential]$Credential,

    [Switch]$Passthru
)

    If ($HostUrl -notmatch "^https?:\/\/") { 
        $HostUrl = "https://{0}" -f $HostUrl  
    }
    $EndPoint = '{0}/api/tokens' -f $HostUrl
    $ApiResponse = (Invoke-WebRequest -Uri $EndPoint -UseBasicParsing -Method Post -Body @{"username"=$Credential.username;"password"=$Credential.GetNetworkCredential().password}).Content 
    $AuthToken = $ApiResponse | ConvertFrom-Json 
    $AuthToken | Add-Member -Name HostUrl -Value $HostUrl -MemberType NoteProperty
    $AuthToken | Add-Member -Name JsonToken -Value $ApiResponse -MemberType NoteProperty
    If ($Passthru) {
        $AuthToken
    }
    Else {
        $script:GuacAuthToken = $AuthToken
    }
}