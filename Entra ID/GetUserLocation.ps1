
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
    Install-Module -Name Microsoft.Graph.Users -Force -Scope CurrentUser
}
Import-Module Microsoft.Graph.Users
Connect-MgGraph -Scopes "User.Read.All"


$users = Get-MgUser -All -Property DisplayName, OfficeLocation
$filelic = Read-Host "Enter the path to save the output"

$users | ForEach-Object {
    [PSCustomObject]@{
        DisplayName = $_.DisplayName
        OfficeLocation = $_.OfficeLocation
    }
} | Export-Csv -Path $filelic -NoTypeInformation

write-host "Users and their office locations exported to $filelic"