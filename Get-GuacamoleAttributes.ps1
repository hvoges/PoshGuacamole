function Get-GuacamoleAttributes {
<#
.SYNOPSIS
    Gets the Object-Attributes from the JSON-String and adds them as Properties
.DESCRIPTION
    The Guacamole-API returns Objects in JSON-Format. This Cmdlet add the JSON-Data as Object-Properties.
    The Cmdlet is only a helper-Function and cannot be called directly.  
.EXAMPLE
    PS C:\> Get-GuacamoleAttributes -object $user -SkipEmptyAttributes
    Adds only Properties with Values
.NOTES
    Author: Holger Voges
    Version: 1.1 
    Date: 2022-02-15
#>
Param(  
        # The Object for which Attributes shall be added   
        $Object,
        
        # Empty Attributes will not be added to the Returned Object
        [Switch]$ShowEmptyAttributes
    )

    # Properties which are defaultet to null instead of an empty string
    $NullProperties = "guac-email-address","guac-organizational-role","guac-full-name","guac-organization","timezone"

    if ( $Object.LastActive ) {
        $Object.LastActive = ConvertFrom-JavaSimpleTime -JavaTime $Object.LastActive
    }

    # Show all User-Attributes, even the empty ones
    if ( $ShowEmptyAttributes ) {
        Foreach ( $Property in  $Object.attributes.psobject.properties ) {
            If (( -not $Object.attributes.($Property.Name))  -and ( $Property.Name -notin $NullProperties )) {
                $Object.attributes.($Property.Name) = ""
            }
            If ( $Property.Name -eq "TimeZone" -and $Property.Value ) {
                Add-Member -InputObject $Object -MemberType $Property.MemberType.tostring() -Name ( Format-GuacamoleString -String $Property.Name ) -Value $Property.Value.Replace('/','_')
            } 
            ElseIf ( $Property.Name -eq "TimeZone" )
            {
                Add-Member -InputObject $Object -MemberType $Property.MemberType.tostring() -Name ( Format-GuacamoleString -String $Property.Name ) -Value $Null
            }
            Else {
                Add-Member -InputObject $Object -MemberType $Property.MemberType.tostring() -Name ( Format-GuacamoleString -String $Property.Name )  -Value $Property.Value
            }
        }
    }
    Else {
        Foreach ( $Property in  $Object.attributes.psobject.properties ) {
            If ( $Object.attributes.($Property.Name)) {
                If ( $Property.Name -eq "TimeZone" ) {
                    Add-Member -InputObject $Object -MemberType $Property.MemberType.tostring() -Name ( Format-GuacamoleString -String $Property.Name ) -Value $Property.Value.Replace('/','_')
                } 
                Else {
                    Add-Member -InputObject $Object -MemberType $Property.MemberType.tostring() -Name ( Format-GuacamoleString -String $Property.Name )  -Value $Property.Value
                }
            }
            If (( -not $Object.attributes.($Property.Name))  -and ( $Property.Name -notin $NullProperties )) {
                $Object.attributes.($Property.Name) = ""
            }            
        }
    }

    $Object
}
