Function New-GuacamoleUser {
    param(
        [Parameter(Mandatory)]
        $AuthToken,

        [string]$Username,

        [string]$Password,

        [bool]$Disabled,

        [bool]$Expired,

        # Hour and Minute of day
        [DateTime]$StartTime,

        # Hour and Minute of day
        [DateTime]$EndTime,

        # Startdate
        [Datetime]$ValidFrom,

        # EndDate
        [Datetime]$ValidUntil,

        [String]$TimeZone,

        [String]$Fullname,

        [string]$Organization,

        [string]$OrganizationRole

    )

$Userproperties = @"
{
    "username": "$UserName",
    "password": "$Password",
    "attributes": {
      "disabled": "$Disabled",
      "expired": "$Expired",
      "access-window-start": "$LongonStartTime",
      "access-window-end": "$LogonEndTime",
      "valid-from": "$ValidFrom",
      "valid-until": "$ValidUntil",
      "timezone": "$timeZone",
      "guac-full-name": "$Fullname",
      "guac-organization": "$Organization",
      "guac-organizational-role": "$OrganizationRole"
    }
  }
"@

    $EndPoint = '{0}/api/session/data/{1}/users?token={2}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$AuthToken.AuthToken

    Write-Verbose $Endpoint
    Invoke-WebRequest -Uri $EndPoint -Method Post -ContentType 'application/json' -Body $UserProperties
}