Function ConvertFrom-JavaSimpleTime {
<#
.SYNOPSIS
    Converts Java-Time to .Net-Datetime
.DESCRIPTION
    Converts Java-Time to .Net-Datetime
    Jave Simple Time uses Januar 1st 1970 as the Zero-Point. Earlier Dates are negative Numbers. 
    Time is measured in Milliseconds. .Net starts from January 1st 0. Time is measured in 1/10.000.000 Seconds.    
.EXAMPLE
    PS C:\> ConvertFrom-JavaSimpleTime -JavaTime 1632749081000
    Connects to your Server and stores an Authentication-Token for further use
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
        [Int64]$JavaTime,

        [Switch]$UTC
    )    
    
    Process {    
        $ReferenceTime = (Get-Date -Date "1970-1-1").Ticks
        $TimeZoneCorrectionMilliSeconds = ((get-date) - (get-date).ToUniversalTime()).TotalMilliSeconds 
        [datetime]::new( $ReferenceTime + $JavaTime*10000 + $TimeZoneCorrectionMilliSeconds * 10000 )
    }
}