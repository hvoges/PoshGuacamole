$ScriptList = dir $PSScriptRoot\*.ps1

foreach ( $Script in $ScriptList )
{
    . $Script.Fullname
}
. $PSScriptRoot\init.ps1