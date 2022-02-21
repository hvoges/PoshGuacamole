Function ConvertTo-HashTable {
    <#
    .SYNOPSIS
        Converts Json to Hashtable
    .DESCRIPTION
        This Cmdlet converts JSON to a Hashtable by Converting to an Object and then to a hashtable
    .EXAMPLE
        Invoke-Restmethod | convertto-Hashtable
    .NOTES
        Author: Holger Voges
        Version: 1.0 
        Date: 2022-21-02
    #>    
        param(
            # Json-String to Convert
            [Parameter(Mandatory,
                       ValueFromPipeline,
                       ParameterSetName='Json')]
            [Alias('LastActive')]                   
            [String]$JsonString,

            [Parameter(Mandatory,
                       ValueFromPipeline,
                       ParameterSetName='Object')]
            # Powershell-Object to Convert
            [PSObject]$InputObject 
        )    
        
        Process {    
            if ( $JsonString ) {
                $InputObject = ConvertFrom-Json -InputObject $JsonString
            }
            $Hashtable = @{}
            Foreach ( $Property in $Object.psobject.Properties )
            {
                $Hashtable.add( $property.Name, $property.Value )
            }
        }

        End {
            $Hashtable
        }
}