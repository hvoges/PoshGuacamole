Function Convertto-GuacamoleTimeString {
    <#
    .SYNOPSIS
        Converts a Datetime to a simple String-Representation of the Date
    .DESCRIPTION
        Converts .Net-Datetime to Java Simple Time
        Jave Simple Time uses Januar 1st 1970 as the Zero-Point. Earlier Dates are negative Numbers. 
        Time is measured in Milliseconds. .Net starts from January 1st 0. Time is measured in 1/10.000.000 Seconds.    
    .EXAMPLE
        PS C:\> Convertto-JavaSimpleTime -Datetime (get-date)
        Converts the Parameter Datetime to a Bigint-Value representing the Milliseconds from January 1st 1970
    .NOTES
        Author: Holger Voges
        Version: 1.0 
        Date: 2021-11-13
    #>    
        param(
            # Java-Time in Integer-Representation
            [Parameter(Mandatory,
                        ValueFromPipeLineByPropertyName,
                        ValueFromPipeline)]
            [Alias('LastActive')]                   
            [DateTime]$DateTime
       )    
        
        Process {    
            "{0:yyyy-mm-dd}" -f $DateTime
        }
    }