if (-not (Get-Module -Name MSOnline -ListAvailable)) {
    Install-Module -Name MSOnline -Force
}
Import-Module -Name MSOnline -Force
Connect-MsolService

$search = Read-Host "Enter the users name" 
Get-MsolUser -SearchString "$search"
