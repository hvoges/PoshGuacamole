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

      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('guac-email-address')]
      [string]$EmailAddress,

      [Parameter(ValueFromPipelineByPropertyName)]
      $Disabled,

      [Parameter(ValueFromPipelineByPropertyName)]
      $Expired,

      # Hour and Minute of day
      [Parameter(ValueFromPipelineByPropertyName)]
      # [Alias('access-window-start')]
      [datetime]$AccessWindowStart,

      # Hour and Minute of day
      [Parameter(ValueFromPipelineByPropertyName)]
      # [Alias('access-window-end')]
      [DateTime]$AccessWindowEnd,

      # Startdate
      [Parameter(ValueFromPipelineByPropertyName)]
      # [Alias('valid-from')]        
      [DateTime]$ValidFrom,

      # EndDate
      [Parameter(ValueFromPipelineByPropertyName)]        
      # [Alias('valid-until')]
      [DateTime]$ValidUntil,

      [Parameter(ValueFromPipelineByPropertyName)]
      # [ValidateSet($GuacamoleTimeZones)]
      [GuacamoleTimeZones]$TimeZone = 'Europe_Berlin',

      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('guac-full-name')]
      [String]$Fullname,
      
      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('guac-organization')]
      [string]$Organization,

      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('guac-organizational-role')]
      [string]$OrganizationRole,

      [Parameter(ValueFromPipelineByPropertyName)]
      [SecureString]$Password,

      [switch]$Passthru,

      [Parameter(DontShow)]
      $AuthToken = $GuacAuthToken
  )

  Process {

    Try {
        $User = Get-GuacamoleUser -Username $Username
    }
    Catch {
        Throw $_
    }

    $ParamList = @{}
    foreach ( $key in ($PSBoundParameters.Keys).GetEnumerator() )
    {
        $ParamList.Add($key,$PSBoundParameters[$key])
    }

    Switch ($ParamList.Keys) {
      "EmailAddress"       { $User.attributes."guac-email-address"       = $EmailAddress }
      "Disabled"           { $User.attributes."disabled"                 = $Disabled }
      "Expired"            { $User.attributes."expired"                  = $Expired }
      "AccessWindowStart"  { $User.attributes."access-window-start"      = $AccessWindowStart.ToString("T") }
      "AccessWindowEnd"    { $User.attributes."access-window-end"        = $AccessWindowEnd.ToString("T") }
      "ValidFrom"          { $User.attributes."valid-from"               = "{0:yyyy-MM-dd}" -f $ValidFrom }
      "ValidUntil"         { $User.attributes."valid-until"              = "{0:yyyy-MM-dd}" -f $ValidUntil }
      "TimeZone"           { $User.attributes."timezone"                 = ([String]$TimeZone).replace("_","/") }
      "Fullname"           { $User.attributes."guac-full-name"           = $Fullname }
      "Organization"       { $User.attributes."guac-organization"        = $Organization }
      "OrganizationalRole" { $User.attributes."guac-organizational-role" = $OrganizationalRole }
    }    

    $Attributes = $User.Attributes 
    $RequestBodyDict = [ordered]@{ 
        username = $Username
        attributes = $Attributes
    } 

    If ( $Password ) {
        $Cred = New-Object -TypeName pscredential -ArgumentList $Username,$Password
        $RequestBodyDict["password"] = $Cred.GetNetworkCredential().Password
    }

    $RequestBody = $RequestBodyDict | ConvertTo-Json

    $EndPoint = '{0}/api/session/data/{1}/users/{2}?token={3}' -f $AuthToken.HostUrl,$AuthToken.Datasource,$User.Username,$AuthToken.AuthToken

    Write-Verbose $Endpoint
    Try {
        $Response = Invoke-RestMethod -Uri $EndPoint -Method Put -ContentType 'application/json' -Body $RequestBody -UseBasicParsing -ErrorAction Stop
    }
    Catch {
        Throw $_ 
    }
    If ( $Passthru ) {
      $Response
    }
  }
}