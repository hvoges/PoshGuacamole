$ScriptList = dir $PSScriptRoot\*.ps1
Write-Host $PSScriptRoot
foreach ( $Script in $ScriptList )
{
    . $Script.Fullname
}