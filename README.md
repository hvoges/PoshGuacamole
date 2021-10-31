# PoshGuacamole
Powershell-Module for User- and Connection-Administration from Powershell

This is a first draft of a Powershell-Module for automating Guacamole-Administration. I uses the Guacamole Web-API documented here:
https://github.com/ridvanaltun/guacamole-rest-api-documentation/tree/master/docs

My Thanks go to Adicitus who made me aware of the Web-Api and who has his own Project which you can find here: https://github.com/Adicitus/ps-guacamole-api.

## Usage 
Before you can use the module, you first have to create an Access-Token for the Web-API with Get-GuacamoleAuthToken. 

```
$token = Get-GuacamoleAuthToken -HostUrl <URL to you Guacamole-Server> -Username <your admin user> -Password <Password>
```

From now on you simply have to pass the token each time you want to access the API. E.g. to get all users, you use Get-GuacamoleUser:

```
Get-GuacamoleUser -AuthToken $token
```

ToDo: Add Pipeline-Functionality, add Documentation

