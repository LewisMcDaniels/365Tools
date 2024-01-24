if (-not (Get-Module -Name MSOnline -ListAvailable)) {
    Install-Module -Name MSOnline -Force
}
Import-Module -Name MSOnline -Force
Connect-MsolService
$domainName = Read-Host "enter the tenant domain name" # Prompt the user to enter the tenant domain name
Get-MsolPasswordPolicy -DomainName $domainName
