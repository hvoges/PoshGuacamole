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

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$Disabled,
   
        [switch]$Passthru,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )
    
    Process {
      $EndPoint = '{0}/api/session/data/{1}/userGroups?token={2}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$AuthToken.AuthToken
  
      $GroupPropertiesDict = [ordered]@{
        identifier = $GroupName
        attributes = [ordered]@{
          "disabled" = ""
        }
      }

      If ( $Disabled ) {
        $GroupPropertiesDict.attributes["disabled"] = "true"
      }


      $GroupProperties = $GroupPropertiesDict | ConvertTo-Json
      Write-Verbose $Endpoint
      $Response = Invoke-RestMethod -Uri $EndPoint -Method Post -ContentType 'application/json' -Body $GroupProperties
      If ( $Passthru ) {
        $Response
      }
    }
}