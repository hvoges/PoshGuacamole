. $PSScriptRoot\init.ps1

. $ScriptRoot\Add-GuacamoleGroupMember.ps1
. $ScriptRoot\Add-GuacamoleUserConnection.ps1
. $ScriptRoot\Connect-Guacamole.ps1
. $ScriptRoot\ConvertFrom-JavaSimpleTime.ps1
. $ScriptRoot\Convertto-GuacamoleTimeString.ps1
. $ScriptRoot\ConvertTo-Hashtable.ps1
. $ScriptRoot\Convertto-JavaSimpleTime.ps1
. $ScriptRoot\Disconnect-Guacamole.ps1
. $ScriptRoot\Format-GuacamoleProperties.ps1
. $ScriptRoot\Get-GuacamoleAttributes.ps1
. $ScriptRoot\Get-GuacamoleConnection.ps1
. $ScriptRoot\Get-GuacamoleConnectionParameter.ps1
. $ScriptRoot\Get-GuacamoleGroupMember.ps1
. $ScriptRoot\Get-GuacamoleUser.ps1
. $ScriptRoot\Get-GuacamoleUserConnection.ps1
. $ScriptRoot\Get-GuacamoleUserGroup.ps1
. $ScriptRoot\Get-GuacamoleUserHistory.ps1
. $ScriptRoot\Get-GuacamoleUserPermission.ps1
. $ScriptRoot\New-GuacamoleRdpConnection.ps1
. $ScriptRoot\New-GuacamoleUser.ps1
. $ScriptRoot\New-GuacamoleUserGroup.ps1
. $ScriptRoot\Remove-GuacamoleAuthToken.ps1
. $ScriptRoot\Remove-GuacamoleConnection.ps1
. $ScriptRoot\Remove-GuacamoleGroupMember.ps1
. $ScriptRoot\Remove-GuacamoleUser.ps1
. $ScriptRoot\Remove-GuacamoleUserConnection.ps1
. $ScriptRoot\Remove-GuacamoleUserGroup.ps1
. $ScriptRoot\Set-GuacamoleRdpConnection.ps1
. $ScriptRoot\Set-GuacamoleUser.ps1
. $ScriptRoot\Set-GuacamoleUserGroup.ps1
. $ScriptRoot\Set-GuacamoleUserPassword.ps1

Export-ModuleMember -Function 'Add-GuacamoleGroupMember','Add-GuacamoleUserConnection','Connect-Guacamole','Disconnect-Guacamole','Get-GuacamoleConnection','Get-GuacamoleConnectionParameter','Get-GuacamoleGroupMember','Get-GuacamoleUser','Get-GuacamoleUserConnection','Get-GuacamoleUserGroup','Get-GuacamoleUserHistory','Get-GuacamoleUserPermission','New-GuacamoleRdpConnection','New-GuacamoleUser','New-GuacamoleUserGroup','Remove-GuacamoleAuthToken','Remove-GuacamoleConnection','Remove-GuacamoleGroupMember','Remove-GuacamoleUser','Remove-GuacamoleUserConnection','Remove-GuacamoleUserGroup','Set-GuacamoleRdpConnection','Set-GuacamoleUser','Set-GuacamoleUserGroup','Set-GuacamoleUserPassword'