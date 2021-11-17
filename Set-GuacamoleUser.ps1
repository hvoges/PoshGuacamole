Function Set-GuacamoleUser {
<#
.SYNOPSIS
    Changes Guacamole User Settings
.DESCRIPTION

.EXAMPLE
    PS C:\> Set-GuacamoleUser -UserName Hans
    Returns the Connection-Settings for the Connection PC12
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-14
#>  
    param(
        [Parameter(Mandatory,
        ValueFromPipelineByPropertyName)]      
        [string]$Username,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName)]
        [string]$Password,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$EmailAddress,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Disabled,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Expired,

        # Hour and Minute of day
        [Parameter(ValueFromPipelineByPropertyName)]
        [DateTime]$StartTime,

        # Hour and Minute of day
        [Parameter(ValueFromPipelineByPropertyName)]
        [DateTime]$EndTime,

        # Startdate
        [Parameter(ValueFromPipelineByPropertyName)]        
        [Datetime]$ValidFrom,

        # EndDate
        [Parameter(ValueFromPipelineByPropertyName)]        
        [Datetime]$ValidUntil,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]$TimeZone,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]$Fullname,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Organization,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$OrganizationRole,

        $AuthToken = $Global:GuacAuthToken
    )

  Process {
      $Userproperties = @"
{
  "username": "$UserName",
  "attributes": {
    "disabled": "$Disabled",
    "expired": "$Expired",
    "access-window-start": "$LongonStartTime",
    "access-window-end": "$LogonEndTime",
    "valid-from": "$ValidFrom",
    "valid-until": "$ValidUntil",
    "timezone": "$timeZone",
    "guac-email-address": "$EmailAddress"
    "guac-full-name": "$Fullname",
    "guac-organization": "$Organization",
    "guac-organizational-role": "$OrganizationRole"
  }
}
"@

      $EndPoint = '{0}/api/session/data/{1}/users?token={2}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$AuthToken.AuthToken

      Write-Verbose $Endpoint
      Invoke-WebRequest -Uri $EndPoint -Method Put -ContentType 'application/json' -Body $UserProperties
  }
}