Function Remove-GuacamoleUser {
<#
.SYNOPSIS
    Removes a Guacamole User-Account
.DESCRIPTION
    
.EXAMPLE
    PS C:\> Get-GuacamoleConnection -ConnectionID PC12
    Returns the Connection-Settings for the Connection PC12
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-14
#>    
    param(
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]   
        [string]$UserName,
        
        $AuthToken = $GuacAuthToken
    )

    Process {
        $EndPoint = '{0}/api/session/data/{1}/users/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$UserName

        Write-Verbose $Endpoint
        Try {
            $Connections = Invoke-RestMethod -Uri $EndPoint -Method Delete -UseBasicParsing -ErrorAction Stop 
        }
        Catch {
            $_
        }
    }
}