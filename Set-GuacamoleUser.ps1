Function Set-GuacamoleUser2 {
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

      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('guac-email-address')]
      [string]$EmailAddress,

      [Parameter(ValueFromPipelineByPropertyName)]
      $Disabled,

      [Parameter(ValueFromPipelineByPropertyName)]
      $Expired,

      # Hour and Minute of day
      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('access-window-start')]
      $StartTime,

      # Hour and Minute of day
      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('access-window-end')]
      $EndTime,

      # Startdate
      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('valid-from')]        
      $ValidFrom,

      # EndDate
      [Parameter(ValueFromPipelineByPropertyName)]        
      [Alias('valid-until')]
      $ValidUntil,

      [Parameter(ValueFromPipelineByPropertyName)]
      [String]$TimeZone = 'Europe/Berlin',

      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('guac-full-name')]
      [String]$Fullname,
      
      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('guac-organization')]
      [string]$Organization,

      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('guac-organizational-role')]
      [string]$OrganizationRole,

      [switch]$Passthru,

      $AuthToken = $Global:GuacAuthToken
  )

  Process {

    Try {
        $User = Get-GuacamoleUser -Username $Username
    }
    Catch {
        Throw "User cannot be found"
    }

    $User = [ordered]@{
      username = $Username
      attributes = [ordered]@{
      }
    }

    $ParamList = @{}
    foreach ( $key in ($PSBoundParameters.Keys).GetEnumerator() )
    {
        if ( $PSBoundParameters[$key] )
        {
            if ( $key -in 'Starttime','EndTime','ValidFrom','ValidUntil') {
                $ParamList.Add($key,[datetime]$PSBoundParameters[$key])
            }
            Else {
                $ParamList.Add($key,$PSBoundParameters[$key])
            }
        }
    }

    Switch ($ParamList.Keys) {
      "EmailAddress"       { $User.attributes."guac-email-address"       = $PSBoundParameters["EmailAddress"] }
      "Disabled"           { $User.attributes."disabled"                 = $PSBoundParameters["Disabled"] }
      "Expired"            { $User.attributes."expired"                  = $PSBoundParameters["Expired"] }
      "StartTime"          { $User.attributes."access-window-start"      = ($PSBoundParameters["Starttime"]).ToString("T") }
      "EndTime"            { $User.attributes."access-window-end"        = ($PSBoundParameters["EndTime"]).ToString("T") }
      "ValidFrom"          { $User.attributes."valid-from"               = "{0:yyyy-MM-dd}" -f $PSBoundParameters["ValidFrom"] }
      "ValidUntil"         { $User.attributes."valid-until"              = "{0:yyyy-MM-dd}" -f $PSBoundParameters["ValidUntil"] }
      "TimeZone"           { $User.attributes."timezone"                 = $PSBoundParameters["TimeZone"] }
      "Fullname"           { $User.attributes."guac-full-name"           = $PSBoundParameters["Fullname"] }
      "Organization"       { $User.attributes."guac-organization"        = $PSBoundParameters["Organization"] }
      "OrganizationalRole" { $User.attributes."guac-organizational-role" = $PSBoundParameters["OrganizationalRole"] }
    }    
<#
      Switch ($ParamList.Keys) {
      "EmailAddress"       { $User.attributes["guac-email-address"]       = $PSBoundParameters["EmailAddress"] }
      "Disabled"           { $User.attributes["disabled"]                 = $PSBoundParameters["Disabled"] }
      "Expired"            { $User.attributes["expired"]                  = $PSBoundParameters["Expired"] }
      "StartTime"          { $User.attributes["access-window-start"]      = ($PSBoundParameters["Starttime"]).ToString("T") }
      "EndTime"            { $User.attributes["access-window-end"]        = ($PSBoundParameters["EndTime"]).ToString("T") }
      "ValidFrom"          { $User.attributes["valid-from"]               = "{0:yyyy-MM-dd}" -f $PSBoundParameters["ValidFrom"] }
      "ValidUntil"         { $User.attributes["valid-until"]              = "{0:yyyy-MM-dd}" -f $PSBoundParameters["ValidUntil"] }
      "TimeZone"           { $User.attributes["timezone"]                 = $PSBoundParameters["TimeZone"] }
      "Fullname"           { $User.attributes["guac-full-name"]           = $PSBoundParameters["Fullname"] }
      "Organization"       { $User.attributes["guac-organization"]        = $PSBoundParameters["Organization"] }
      "OrganizationalRole" { $User.attributes["guac-organizational-role"] = $PSBoundParameters["OrganizationalRole"] }
    }    
#>

    $Attributes = $User.Attributes | ConvertTo-Json
    $RequestBody = @{ 
        username = $Username
        attributes = $Attributes
    }

    $EndPoint = '{0}/api/session/data/{1}/users/{2}?token={3}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$User.Username,$AuthToken.AuthToken

    Write-Verbose $Endpoint
    $RequestBody
    $Response = Invoke-RestMethod -Uri $EndPoint -Method Put -ContentType 'application/json' -Body $RequestBody 4>&1
    If ( $Passthru ) {
      $Response
    }
  }
}