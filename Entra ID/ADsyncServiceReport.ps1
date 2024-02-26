# Run on local machine where AD sync is installed

$svcaccount = (Get-WmiObject Win32_Service -Filter "Name='adsync'").StartName
Write-Host "ADSync service is running as $svcaccount" -ForegroundColor Green
Get-Service -Name adsync | 
Select-Object -Property Name, Status, StartType, DisplayName, DependentServices | 
Format-List
