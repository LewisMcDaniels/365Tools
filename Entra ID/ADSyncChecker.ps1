if (-not (Get-Module -Name MSOnline -ListAvailable)) {
    Install-Module -Name MSOnline -Force
}
Import-Module -Name MSOnline -Force
Connect-MsolService

$companyInfo = Get-MsolCompanyInformation
$companyname = $companyInfo | Select-Object -ExpandProperty DisplayName
$lastsync = $companyInfo | Select-Object -ExpandProperty LastDirSyncTime
$lastpasswdsync = $companyInfo | Select-Object -ExpandProperty LastPasswordSyncTime
$SrvName = (Get-MsolCompanyInformation).DirSyncClientMachineName
Write-Host "Company Name: $companyname"
Write-Host "Last DirSync: $lastsync"
Write-Host "Last Password Sync: $lastpasswdsync"
Write-Host "AAD Connect Server Name: $SrvName"