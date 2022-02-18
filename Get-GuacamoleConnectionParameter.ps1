Function Get-GuacamoleConnectionParameter {
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
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [Alias('identifier')]
        [string]$ConnectionID,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

    process {
        $EndPoint = '{0}/api/session/data/{1}/connections/{3}/parameters?token={2}' -f $AuthToken.HostUrl,$AuthToken.datasource,$AuthToken.authToken,$ConnectionID

        Write-Verbose $Endpoint
        Try {
            $WebResponse = Invoke-WebRequest -Uri $EndPoint -UseBasicParsing 
            $ConnectionSettings = $WebResponse.Content | ConvertFrom-Json
            $ConnectionSettings.Password = ConvertTo-SecureString -String $ConnectionSettings.password -AsPlainText -Force
            $Content = $WebResponse.Content -replace '"password":".*?"','"password":"*"'
            $ConnectionSettings | Add-Member -MemberType NoteProperty -Name attributes -Value $Content
        }
        Catch {
            Throw $_
        }
        $ConnectionSettings
    }
}