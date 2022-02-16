Function Remove-GuacamoleAuthToken {
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
        $AuthToken = $GuacAuthToken
    )   

    $EndPoint = '{0}/api/tokens/{1}' -f $AuthToken.HostUrl,$AuthToken.authToken
    Write-Verbose -Message $EndPoint
    $Response = Invoke-WebRequest -Uri $EndPoint -Method Delete
}