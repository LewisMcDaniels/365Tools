# Ensure required module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell)) {
  Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -Scope CurrentUser
}

Import-Module Microsoft.Online.SharePoint.PowerShell

# Connect to SharePoint Online (prompt for credentials)
$adminUrl = Read-Host "Enter your SharePoint Online admin center URL (e.g., https://contoso-admin.sharepoint.com)"
Connect-SPOService -Url $adminUrl

# Get all OneDrive site collections (personal sites)
$oneDriveSites = Get-SPOSite -Template "SPSPERS" -Limit All

$results = foreach ($site in $oneDriveSites) {
  # Get site admins
  $admins = Get-SPOUser -Site $site.Url | Where-Object { $_.IsSiteAdmin -eq $true }
  [PSCustomObject]@{
    OneDriveUrl = $site.Url
    SiteAdmins  = if ($admins) { ($admins | Select-Object -ExpandProperty LoginName) -join '; ' } else { "" }
  }
}

# Export to CSV
$csvPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "SiteCollectionAdmins.csv")
$results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "Export complete: $csvPath"