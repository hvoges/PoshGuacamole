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
        [Switch]$SkipEmptyAttributes
    )

    # Properties which are defaultet to null instead of an empty string
    $NullProperties = "guac-email-address","guac-organizational-role","guac-full-name","guac-organization","timezone"

    if ( $Object.LastActive ) {
        $Object.LastActive = ConvertFrom-JavaSimpleTime -JavaTime $Object.LastActive
    }

    if ( $SkipEmptyAttributes ) {
        Foreach ( $Property in  $Object.attributes.psobject.properties ) {
            If ( $Object.attributes.($Property.Name)) {
                Add-Member -InputObject $Object -MemberType $Property.MemberType.tostring() -Name $Property.Name -Value $Property.Value
            }
        }
    }
    Else {
        Foreach ( $Property in  $Object.attributes.psobject.properties ) {
            If (( -not $Object.attributes.($Property.Name))  -and ( $Property.Name -notin $NullProperties ))
            {
                $Object.attributes.($Property.Name) = ""
            }
            Add-Member -Inputobject $Object -MemberType $Property.MemberType.tostring() -Name $Property.Name -Value $Property.Value
        }
    }

    $Object
}
