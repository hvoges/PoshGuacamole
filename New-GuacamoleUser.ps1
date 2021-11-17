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
        [string]$Password,

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
        [DateTime]$StartTime,

        # Hour and Minute of day
        [Parameter(ValueFromPipelineByPropertyName)]
        [DateTime]$EndTime,

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
    $user = [ordered]@{
      username = $Username
      Password = $Password
      attributes = [ordered]@{
      }
    }

    Switch ($PSBoundParameters.Keys) {
      "EmailAddress"       { $user.attributes["guac-email-address"]       = $PSBoundParameters["EmailAddress"] }
      "Disabled"           { $user.attributes["Disabled"]                 = $PSBoundParameters["Disabled"] }
      "Expired"            { $user.attributes["expired"]                  = $PSBoundParameters["Expired"] }
      "StartTime"          { $user.attributes["access-window-start"]      = ($PSBoundParameters["Starttime"]).ToString("T") }
      "EndTime"            { $user.attributes["access-window-end"]        = ($PSBoundParameters["EndTime"]).ToString("T") }
      "ValidFrom"          { $user.attributes["valid-from"]               = "{0:yyyy-MM-dd}" -f $PSBoundParameters["ValidFrom"] }
      "ValidUntil"         { $user.attributes["valid-until"]              = "{0:yyyy-MM-dd}" -f $PSBoundParameters["ValidUntil"] }
      "TimeZone"           { $user.attributes["timezone"]                 = $PSBoundParameters["TimeZone"] }
      "Fullname"           { $user.attributes["guac-full-name"]           = $PSBoundParameters["Fullname"] }
      "Organization"       { $user.attributes["guac-organization"]        = $PSBoundParameters["Organization"] }
      "OrganizationalRole" { $user.attributes["guac-organizational-role"] = $PSBoundParameters["OrganizationalRole"] }
    }
    $UserProperties = $user | ConvertTo-Json
    $EndPoint = '{0}/api/session/data/{1}/users?token={2}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$AuthToken.AuthToken

    Write-Verbose $Endpoint
    Invoke-WebRequest -Uri $EndPoint -Method Post -ContentType 'application/json' -Body $UserProperties
  }
}