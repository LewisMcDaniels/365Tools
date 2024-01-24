if (-not (Get-Module -Name MSOnline -ListAvailable)) {
    Install-Module -Name MSOnline -Force
}
Import-Module -Name MSOnline -Force
Connect-MsolService

# Get the current UPN
$cupn = Read-Host "Enter the users current UPN" 
$nupn = Read-Host "Enter the users new UPN"
Set-MsolUserPrincipalName -UserPrincipalName "$cupn" -NewUserPrincipalName "$nupn"