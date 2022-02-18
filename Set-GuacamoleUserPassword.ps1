Function Set-GuacamoleUserPassword {
<#
.SYNOPSIS
    Resets the User-Password
.DESCRIPTION
    This Command sets a new Password. It can be used via Pipeline to reset multiple-User Passwords 
    to the same value. 
.EXAMPLE
    Reset the Password of a single user
    PS C:\> $Password = Convertto-SecureString -String "Password" -AsPlainText -Force
    PS C:\> Set-GuacamoleUserPassword -User John -Password $Password
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2022-18-02
#>    
    param(
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [string]$Username,
        
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [SecureString]$Password,

        $AuthToken = $GuacAuthToken
    )

    Process {
        Try {
            $User = Get-GuacamoleUser -Username $Username
        }
        Catch {
            Throw $_
        }
        
        $Cred = New-Object -TypeName pscredential -ArgumentList $Username,$Password

        $RequestBody = [ordered]@{ 
            username = $Username
            password = $Cred.GetNetworkCredential().Password
            attributes = $User.attributes
        } | ConvertTo-Json
    
        $EndPoint = '{0}/api/session/data/{1}/users/{2}?token={3}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$User.Username,$AuthToken.AuthToken
    
        Write-Verbose $Endpoint
        Try {
            $Response = Invoke-RestMethod -Uri $EndPoint -Method Put -ContentType 'application/json' -Body $RequestBody -UseBasicParsing -ErrorAction Stop
        }
        Catch {
            Throw $_ 
        }
      }
    }