function Format-GuacamoleString {
    <#
    .SYNOPSIS
        Reformats the Names of Guacamole Attributes
    .DESCRIPTION
        The Properties of Guacamole-Objects are formated with _ instead of Camel-Case. This Functions reformats a string to Camel-Case
        by removing separator-Characters and changing the case of each first character to Upper-Case
    .EXAMPLE
        PS C:\> Format-GuacamoleProperties -Separator _ -String guac_email_address
        Returns GuacEmailAddress
    .NOTES
        Author: Holger Voges
        Version: 1.0 
        Date: 2022-02-16
    #>
    Param(  
            # The String which has to be reformated
            [string]$String,
            
            # The Separator-Character which has to be removed
            [String]$Separator = '-'
        )
       
        $SubstringList = @( $String.Split( $Separator ))
        $SingleStrings = Foreach ( $Substring in $SubstringList )
        {
            $Substring[0].ToString().ToUpper() + $Substring.Substring(1)
        }
        $SingleStrings -join ""
}
    