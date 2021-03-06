Function Remove-GuacamoleUserGroup {
    <#
    .SYNOPSIS
        Removes a new Guacamole User Group
    .DESCRIPTION
    
    .EXAMPLE
        PS C:\> Remove-GuacamoleUserGroup -GroupName Guests
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

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )
    
    Process {
      $EndPoint = '{0}/api/session/data/{1}/userGroups/{3}?token={2}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$AuthToken.AuthToken,$GroupName

      Write-Verbose $Endpoint
      Try {
        $Response = Invoke-RestMethod -Uri $EndPoint -Method Delete
      }
      Catch {

      }
      If ( $Passthru ) {
        $Response
      }
    }
}