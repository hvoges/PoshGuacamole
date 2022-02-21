Function ConvertFrom-JsonToHashTable {
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
            [Parameter(Mandatory,
                       ValueFromPipeline)]
            [Alias('LastActive')]                   
            [String]$JsonString
        )    
        
        Process {    
            $JsonAsObject = ConvertFrom-Json -InputObject $JsonString
            $Hashtable = @{}
            Foreach ( $Property in $JsonAsObject.psobject.Properties )
            {
                $Hashtable.add( $property.Name, $property.Value )
            }
        }

        End {
            $Hashtable
        }
}