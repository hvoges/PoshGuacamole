New-Variable -Scope Script -name GuacamoleTimezones -Option Constant -Value "Europe/Amsterdam","Europe/Andorra","Europe/Athens","Europe/Belfast","Europe/Belgrade","Europe/Berlin","Europe/Bratislava","Europe/Brussels","Europe/Bucharest","Europe/Budapest","Europe/Busingen","Europe/Chisinau","Europe/Copenhagen","Europe/Dublin","Europe/Gibraltar","Europe/Guernsey","Europe/Helsinki","Europe/IsleOfMan","Europe/Isanbul","Europe/Jersey"
$GuacamoleTimezones


Enum GuacamoleTimezones {
    Europe_Amsterdam
    Europe_Andorra
    Europe_Athens
    Europe_Belfast
    Europe_Belgrade
    Europe_Berlin
    Europe_Bratislava
    Europe_Brussels
    Europe_Bucharest
    Europe_Budapest
    Europe_Busingen
    Europe_Chisinau
    Europe_Copenhagen
    Europe_Dublin
    Europe_Gibraltar
    Europe_Guernsey
    Europe_Helsinki
    Europe_IsleOfMan
    Europe_Isanbul
    Europe_Jersey
}

[GuacamoleTimezones]::Europe_Amsterdam