Function New-GuacamoleUser {
<#
.SYNOPSIS
    Creates a new Guacamole User
.DESCRIPTION

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
        ValueFromPipelineByPropertyName)]      
        [string]$Username,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [securestring]$Password,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$EmailAddress,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Disabled,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Expired,

        # Startdate
        [Parameter(ValueFromPipelineByPropertyName)]        
        [ValidateScript({ If ( $_ -lt ( get-date )) { Throw "Das Startdatum liegt in der Vergangenheit" }; $true })]
        [DateTime]$ValidFrom,

        # EndDate
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ If ( $_ -le $ValidFrom ) { Throw "Das Enddatum liegt vor dem Startdatum"}; $true })]
        [DateTime]$ValidUntil,        

        # Hour and Minute of day
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('access-window-start')]
        [DateTime]$AccessWindowStart,

        # Hour and Minute of day
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('access-window-end')]
        [DateTime]$AccessWindowEnd,

        [Parameter(ValueFromPipelineByPropertyName)]
        [GuacamoleTimeZones]$TimeZone,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]$Fullname,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Organization,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OrganizationRole,

        [switch]$Passthru,

        [Parameter(DontShow)]
        $AuthToken = $GuacAuthToken
    )

  Process {
    $user = [ordered]@{
      username = $Username
      password = [PSCredential]::new('Demo',$Password).GetNetworkCredential().Password
      attributes = [ordered]@{
      }
    }

    Switch ($PSBoundParameters.Keys) 
    {
      "EmailAddress"       { $User.attributes."guac-email-address"       = $EmailAddress }
      "Disabled"           { $User.attributes."disabled"                 = $Disabled }
      "Expired"            { $User.attributes."expired"                  = $Expired }
      "AccessWindowStart"  { $User.attributes."access-window-start"      = $AccessWindowStart.ToString("T") }
      "AccessWindowEnd"    { $User.attributes."access-window-end"        = $AccessWindowEnd.ToString("T") }
      "ValidFrom"          { $User.attributes."valid-from"               = "{0:yyyy-MM-dd}" -f $ValidFrom }
      "ValidUntil"         { $User.attributes."valid-until"              = "{0:yyyy-MM-dd}" -f $ValidUntil }
      "TimeZone"           { $User.attributes."timezone"                 = $Timezones."$TimeZone" }
      "Fullname"           { $User.attributes."guac-full-name"           = $Fullname }
      "Organization"       { $User.attributes."guac-organization"        = $Organization }
      "OrganizationalRole" { $User.attributes."guac-organizational-role" = $OrganizationalRole }
    }    

    $UserProperties = $user | ConvertTo-Json
    $EndPoint = '{0}/api/session/data/{1}/users?token={2}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$AuthToken.AuthToken

    Write-Verbose $Endpoint
    $Response = Invoke-RestMethod -Uri $EndPoint -Method Post -ContentType 'application/json' -Body $UserProperties
    If ( $Passthru ) {
      $Response
    }
  }
}