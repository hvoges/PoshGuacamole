function Get-GuacamoleAttributes {
<#
.SYNOPSIS
    Open a Object to your Guacamole-Server 
.DESCRIPTION
    This Cmdlet gets an Authentication-Token for the Guacamole Web-Service. You have to initialize a Object with this cmdlet
    before you can control your server. 
.EXAMPLE
    PS C:\> Connect-Guacamole -HostUrl https://myGuacamole.io -Credential Guacadmin
    Connects to your Server and stores an Authentication-Token for further use
.NOTES
    Author: Holger Voges
    Version: 1.0 
    Date: 2021-11-13
#>
Param( $Object )

    if ( $Object.LastActive ) {
        $Object.LastActive = ConvertFrom-JavaSimpleTime -JavaTime $Object.LastActive
    }
    Foreach ( $Property in  $Object.attributes.psobject.properties ) {
        Add-Member -InputObject $Object -MemberType $Property.MemberType.tostring() -Name $Property.Name -Value $Property.Value
    } 
    $Object
}
