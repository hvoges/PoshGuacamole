Function Remove-GuacamoleAuthToken {
    param(
        $AuthToken
    )   

    $EndPoint = '{0}/api/tokens/{1}' -f $AuthToken.HostUrl,$AuthToken.authToken
    Write-Verbose -Message $EndPoint
    $Response = Invoke-WebRequest -Uri $EndPoint -Method Delete
}