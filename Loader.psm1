$ScriptList = dir $PSScriptRoot\*.ps1 -Exclude init.ps1
. $PSScriptRoot\init.ps1

foreach ( $Script in $ScriptList )
{
    . $Script.Fullname
}

Export-ModuleMember -Function * -Variable keyboardCodes