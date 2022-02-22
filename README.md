# PoshGuacamole

This is a Powershell-Module for User- and Connection-Administration from Powershell. It uses the Guacamoles Rest-API. You find a rudimentary documentation here:
https://github.com/ridvanaltun/guacamole-rest-api-documentation/tree/master/docs

This Project is currently beta and does not support all features of the Web-GUI. Nevertheless, you can already use it for user- and Connection-Management. 
Feel free to add your own functionality to the Module. The Module was last updated on 02-22-2022. 

My Thanks go to Adicitus who made me aware of the Web-Api and who has his own Project which you can find here: https://github.com/Adicitus/ps-guacamole-api.

## Usage

Before you can use the cmdlets, you first have to authorize. This what Connect-Guacamole does for you. The cmdlet creates a Session-Token which will be stored in a Script-Variable and is not accessible outside of the Cmdlet. If you need the session-Token for Authenticatin outside the module, you can use the *-Passthru* Parameter.

```powershell
$Credential = Get-Credential
Connect-Guacamole -HostUrl guacamole.mycompany.com -Credential guacadmin

# if you need the Token outside the module
$AuthToken = Connect-Guacamole -HostUrl guacamole.mycompany.com -Credential $Crential -Passthru
$AuthToken.authToken
```

Now you can query your users, connections or groups.  

```powershell
# Return all users.
Get-GuacamoleUser
# Return a single user
Get-GuacamoleUser -UserName Guacadmin
# Return all Connections
Get-Guacamoleconnection
# Return only RDP-Connections
Get-GuacamoleConnection -Protocol rdp
# Return a single connection
Get-GuacamoleConnection -ConnectionName PC5
# or use the Connection-ID
Get-GuacamoleConnection -ConnectionID 41 
# To get the Connection-Parameters, use -Includeconnectionsparameter
$ConnParam = Get-Guacamoleconnection -Connectionname PC5 -IncludeConnectionParameter
$ConnParam.ConnectionParameter
# You can get only the Connection-Parameter also
Get-GuacamoleConnectionParameter -ConnectionID 41
# To return groups 
Get-GuacamoleUserGroup
```

There are also Cmdlet for User- and Connection-Creation

```powershell
# Create a new User with New-Guacamoleuser. Passwords have to be Secure strings, Dates and Times will be handed over as [datetime]
$Password = Convertto-SecureString -String "Passw0rd" -AsPlainText -Force
New-GuacamoleUser -Username john -Password Passw0rd -EmailAddress "John@mycomany.com" -ValidFrom (get-date).adddays(10) -ValidUntil (get-date).adddays(20)
# To change existing users, use Set-GuacamoleUser
Set-GuacamoleUser -TimeZone Europe_Berlin
# You even can pipe exisiting users to Set-GuacamoleUser
Get-GuacamoleUser | Set-GuacamoleUser -Disabled $true
# To Create a new RDP-Connection, use New-GuacamoleRdpConnection
$Password = Convertto-SecureString -String "Passw0rd" -AsPlainText -Force
New-GuacamoleRdpConnection -Hostname client1 -UserName user1 -UserPassword $Password -UserDomain netz-weise.de -IgnoreCertificateWarning $true
# You can change the Connection with Set-GuacamoleRdpconnection
Set-GuacamoleRdpConnection -Connectionname democlient -ServerLayout German
# or set Connections via Pipeline
Get-GuacamoleConnection | Where-Object { $_.name -like "demo*"  } | Set-GuacamoleRdpConnection -SecurityMode nla-ext
```

A User can access a Connection, if he has Read-Permission. 


```powershell
# Show all the Connections a user can access
Get-GuacamoleUserConnection -Username john
# Add an additional Connection for the user
Add-GuacamoleUserConnection -Username john -ConnectionName DemoClient
# Or remove a Connection
Remove-GuacamoleUserconnection -UserName john -ConnectionName DemoClient
```

To Remove Users or Connections, use the corresponding Remove-Cmdlets

```powershell
Remove-GuacamoleUser -UserName hans
# To remove multiple users, you can use the Pipeline - be careful with this Command!
Get-GuacamoleUser | Where-Object username -like "demo*" | Remove-GuacamoleUser
# and the same with Connections
Remove-GuacamoleConnection -ConnectionName democlient
```

As always in Powershell, a successfull removal will not be prompted, only errors will be shown. 

## ToDo
Implementing Whatif-Parameter for the Set- and Remove-Cmdlets
Implementing Cmdlets for VNC, SSH, Telnet and Kubernetes
Implementing Connection-Groups
Permission-Management
Disconnect Sessions
