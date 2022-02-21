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

Enum KeyboardLayout {
    Danish
    Brazilian_Portugese
    English_UK
    English_US
    French
    French_Belgian
    French_Swiss
    German
    German_Swiss
    Hungarian
    Italian
    Japanese
    Norwegian
    Spanish
    Spanish_Latin_American
    Swedish
    Turkish
    Unicode
}

$Script:keyboardCodes = @{
    Danish = 'da-dk-qwerty'
    Brazilian_Portugese = 'pt-br-qwerty'
    English_UK = 'en-gb-qwerty'
    English_US = 'en-us-qwerty'
    French = 'fr-fr-azerty'
    French_Belgian = 'fr-be-azerty'
    French_Swiss = 'fr-ch-qwertz'
    German = 'de-de-qwertz'
    German_Swiss = 'de-ch-qwertz'
    Hungarian = 'hu-hu-qwertz'
    Italian = 'it-it-qwerty'
    Japanese = 'ja-jp-qwerty'
    Norwegian = 'no-no-qwerty'
    Spanish = 'es-es-qwerty'
    Spanish_Latin_American = 'es-latam-qwerty'
    Swedish = 'sv-se-qwerty'
    Turkish = 'tr-tr-qwerty'  
    Unicode = 'failsafe'
}