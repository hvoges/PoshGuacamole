Function New-GuacamoleUserGroup {
    <#
    .SYNOPSIS
        Creates a new Guacamole User Group
    .DESCRIPTION
    
    .EXAMPLE
        PS C:\> New-GuacamoleUserGroup
    .NOTES
        Author: Holger Voges
        Version: 1.0 
        Date: 2022-02-18
    #>  
    param(
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName)]      
        [Alias('identifier')]
        [string]$GroupName,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [switch]$Disabled,
   
        [switch]$Passthru,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )
    
    Process {
      $EndPoint = '{0}/api/session/data/{1}/userGroups?token={2}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$AuthToken.AuthToken
  
 
      If (-not $Disabled ) {
          $Disabled = ""
      }
      $GroupProperties = [ordered]@{
        identifier = $Username
        attributes = [ordered]@{
           disabled = $Disabled
        }
      }
  
      Write-Verbose $Endpoint
      $Response = Invoke-RestMethod -Uri $EndPoint -Method Post -ContentType 'application/json' -Body $GroupProperties
      If ( $Passthru ) {
        $Response
      }
    }
}