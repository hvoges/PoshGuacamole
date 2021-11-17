Function Convertto-JavaSimpleTime {
<#
.SYNOPSIS
    Converts .Net-Datetime to Java Simple Time
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
        [DateTime]$DateTime,

        [Switch]$UTC
    )    
    
    Process {    
        $ReferenceTime = (Get-Date -Date "1970-1-1").Ticks
        $TimeZoneCorrectionMilliSeconds = ((get-date) - (get-date).ToUniversalTime()).TotalMilliSeconds 
        [Math]::Round(( $DateTime.Ticks - $ReferenceTime ) / 10000 - $TimeZoneCorrectionMilliSeconds )
    }
}