$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSEdition -ne 'Desktop') { Write-Host 'Run this in Windows PowerShell Desktop 5.1.' ; return }
if (Get-Module PnP.PowerShell -ErrorAction SilentlyContinue) { Remove-Module PnP.PowerShell -Force }
if (-not (Get-Module -ListAvailable Microsoft.Online.SharePoint.PowerShell)) { Install-Module Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force }
Import-Module Microsoft.Online.SharePoint.PowerShell -Force

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$AdminCenterUrl = Read-Host "Enter the SharePoint Admin Center URL (e.g. https://yourtenant-admin.sharepoint.com)"
$OutputFile = Read-Host "Enter the output CSV file path (e.g. C:\Temp\SharePointSiteAdmins.csv)"

# Connect to SharePoint Online first
Connect-SPOService -Url $AdminCenterUrl

# Prompt user for site selection mode
$siteSelectionMode = Read-Host "Select an option:
1 - Process all SharePoint sites (can be slow)
2 - Use specific site URLs
3 - Process OneDrive personal sites (/personal/* sites)
Enter your choice (1, 2, or 3)"

$AllSites = $false
if ($siteSelectionMode -eq "1") {
	$AllSites = $true
	Write-Host "Processing all SharePoint sites..." -ForegroundColor Cyan
}
elseif ($siteSelectionMode -eq "2") {
	Write-Host "Using predefined site list from script..." -ForegroundColor Cyan
}
elseif ($siteSelectionMode -eq "3") {
	Write-Host "Processing OneDrive personal sites..." -ForegroundColor Cyan
	$TargetSites = Get-SPOSite -IncludePersonalSite $true -Limit All | 
		Where-Object { $_.Url -like "*/personal/*" } | 
		Select-Object -ExpandProperty Url
	Write-Host "Found $($TargetSites.Count) OneDrive personal sites" -ForegroundColor Cyan
}
else {
	Write-Host "Invalid selection. Using predefined site list as default." -ForegroundColor Yellow
}
if (-not $AllSites -and $siteSelectionMode -ne "3") {
	$siteInput = Read-Host "Enter SharePoint site URLs (separate multiple URLs with commas)"
	if ([string]::IsNullOrWhiteSpace($siteInput)) {
		Write-Host "No sites provided. Exiting script." -ForegroundColor Yellow
		exit
	} else {
		$TargetSites = $siteInput -split ',' | ForEach-Object { $_.Trim() }
		Write-Host "Processing the following sites:" -ForegroundColor Cyan
		$TargetSites | ForEach-Object { Write-Host "  - $_" -ForegroundColor Cyan }
	}
}

if ($AllSites) { $TargetSites = (Get-SPOSite -Limit All | Select-Object -ExpandProperty Url) }

$results = foreach ($url in $TargetSites) {
	try {
		Get-SPOSite -Identity $url | Out-Null
		Get-SPOUser -Site $url -Limit All | Where-Object { $_.IsSiteAdmin } | ForEach-Object {
			[pscustomobject]@{ SiteUrl = $url; AdminLoginName = $_.LoginName}
		}
	} catch { Write-Host "SKIP $url : $($_.Exception.Message)" -ForegroundColor Yellow }
}

$results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
Write-Host "Exported $($results.Count) admin entries -> $OutputFile"