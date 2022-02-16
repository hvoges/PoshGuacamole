# PoshGuacamole

Powershell-Module for User- and Connection-Administration from Powershell

This project is currently in Beta. Its purpose it to automate Apache Guacamole Administration via Powershell. I used the Guacamole Web-API documented here:
https://github.com/ridvanaltun/guacamole-rest-api-documentation/tree/master/docs

My Thanks go to Adicitus who made me aware of the Web-Api and who has his own Project which you can find here: https://github.com/Adicitus/ps-guacamole-api.

## Usage

Before you can use the Cmdlets, you first have to create an Access-Token for the Web-API with Connect-Guacamole.

```powershell
Connect-Guacamole -HostUrl guacamole.mycompany.com -Credential guacadmin
```

Now you can query your users, connections or groups.  

```powershell
Get-GuacamoleUser 
Get-GuacamoleUser -UserName Guacadmin
Get-Guacamoleconnection
Get-Guacamoleconnection -IncludeConnectionParameter
Get-GuacamoleUserPermission -UserName Guacadmin
```

You can Create and Set Users

```powershell
New-GuacamoleUser -Username john -Password Passw0rd -EmailAddress John@mycomany.com -ValidFrom (get-date).adddays(10) -ValidUntil (get-date).adddays(20)
Get-GuacamoleUser -Username john | Set-GuacamoleUser -Disabled $true
```
