#Install SharePoint Online Management Shell Module
if (Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable) {
    Write-Host "Microsoft.Online.SharePoint.PowerShell Module is installed!" -f Green
}
else {
    Write-Host "Microsoft.Online.SharePoint.PowerShell Module is NOT installed!" -f Red
    Write-Host "Installing Microsoft.Online.SharePoint.PowerShell Module..." -f Yellow
    Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -AllowClobber -Verbose
}
#Variable for SharePoint Online Admin Center URL
$AdminSiteURL= Read-Host "Enter the SharePoint Online Admin Center URL"
$CSVFile = "C:\OneDrives.csv"

Import-Module Microsoft.Online.SharePoint.PowerShell
#Connect to SharePoint Online Admin Center
Connect-SPOService -Url $AdminSiteURL -credential (Get-Credential)
 
#Get All OneDrive Sites usage details and export to CSV
Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'" | 
Select-Object URL, Owner, StorageQuota, StorageUsageCurrent, LastContentModifiedDate | 
Export-Csv -Path $CSVFile -NoTypeInformation
