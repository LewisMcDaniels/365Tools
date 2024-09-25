# Install the SharePoint Online Management Shell module
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -AllowClobber

# Import the SharePoint Online Management Shell module
Import-Module -Name Microsoft.Online.SharePoint.PowerShell

# Connect to SharePoint Online
$SPOTenant = Read-Host "Enter the URL of your SharePoint Online tenant (e.g. https://contoso-admin.sharepoint.com)"
Connect-SPOService -Url $SPOTenant

# Get all site collections
$sites = Get-SPOSite -Limit All

$nonPointPublishingSites = $sites | Where-Object { 
    $_.Template -ne "POINTPUBLISHINGTOPIC" -and 
    $_.Template -ne "POINTPUBLISHINGHUB" -and 
    $_.Url -match "/sites/"
}

# List the current state of custom scripting on each site collection
Write-Host "Custom Scripting State for All Site Collections:" -ForegroundColor Green
foreach ($site in $nonPointPublishingSites) {
    $siteUrl = $site.Url
    $customScriptState = Get-SPOSite -Identity $siteUrl | Select-Object -ExpandProperty DenyAddAndCustomizePages
    $customScriptStatus = if ($customScriptState -eq [Microsoft.Online.SharePoint.TenantAdministration.DenyAddAndCustomizePagesStatus]::Disabled) { "Allowed" } else { "Blocked" }
    
    Write-Output "Site URL: $siteUrl - Custom Script: $customScriptStatus"
}

Write-Host "Loading options" -ForegroundColor Green
Write-Host

do {
    write-host
    Write-Host
    Write-Host
    Write-Host "Select an option:" -ForegroundColor Cyan
    Write-Host "1. Enable custom scripting on all sites"
    Write-Host "2. Enable custom scripting on a specific site"
    Write-Host "3. List the state of custom scripting on all site collections"
    write-host "4. Disable custom scripting on all sites"
    write-host "5. Disable custom scripting on a specific site"
    Write-Host "0. Quit" -ForegroundColor Red
    
    $option = Read-Host "Enter your choice (0-5)"

    switch ($option) {
        1 {
           
            Write-Host "Enabling custom scripting on all sites" -ForegroundColor Yellow
            foreach ($site in $nonPointPublishingSites) {
                Set-SPOSite -Identity $site.Url -DenyAddAndCustomizePages $false
                Write-Host "Enabled custom scripting on site: $($site.Url)" -ForegroundColor Green
            }
        }
        2 {
            $siteUrl = Read-Host "Enter the URL of the site to enable custom scripting"
            $site = Get-SPOSite -Identity $siteUrl -ErrorAction SilentlyContinue
            if ($null -ne $site) {
                Set-SPOSite -Identity $siteUrl -DenyAddAndCustomizePages $false
                $customScriptState = Get-SPOSite -Identity $siteUrl | Select-Object -ExpandProperty DenyAddAndCustomizePages
                $customScriptStatus = if ($customScriptState -eq [Microsoft.Online.SharePoint.TenantAdministration.DenyAddAndCustomizePagesStatus]::Disabled) { "Allowed" } else { "Blocked" }
                Write-Host "Custom scripting state: $siteUrl - Current State: $customScriptStatus" -ForegroundColor Green
            } else {
                Write-Host "Site not found: $siteUrl" -ForegroundColor Red
            }
        }
        3 {

            Write-Host "Custom Scripting State for all sites:" -ForegroundColor Green
            foreach ($site in $nonPointPublishingSites) {
                $siteUrl = $site.Url
                $customScriptState = Get-SPOSite -Identity $siteUrl | Select-Object -ExpandProperty DenyAddAndCustomizePages
                $customScriptStatus = if ($customScriptState -eq [Microsoft.Online.SharePoint.TenantAdministration.DenyAddAndCustomizePagesStatus]::Disabled) { "Allowed" } else { "Blocked" }
                Write-Output "Site URL: $siteUrl - Custom Script: $customScriptStatus"
            }
        }
        4 {

            Write-Host "Disabling custom scripting on all sites" -ForegroundColor Yellow
            foreach ($site in $nonPointPublishingSites) {
                Set-SPOSite -Identity $site.Url -DenyAddAndCustomizePages $true
                Write-Host "Disabled custom scripting on site: $($site.Url)" -ForegroundColor Green
            }
        }
        5 {
            
            $siteUrl = Read-Host "Enter the URL of the site to disable custom scripting"
            $site = Get-SPOSite -Identity $siteUrl -ErrorAction SilentlyContinue
            if ($null -ne $site) {
                Set-SPOSite -Identity $siteUrl -DenyAddAndCustomizePages $true
                $customScriptState = Get-SPOSite -Identity $siteUrl | Select-Object -ExpandProperty DenyAddAndCustomizePages
                $customScriptStatus = if ($customScriptState -eq [Microsoft.Online.SharePoint.TenantAdministration.DenyAddAndCustomizePagesStatus]::Disabled) { "Allowed" } else { "Blocked" }
                Write-Host "Custom scripting state: $siteUrl - Current State: $customScriptStatus" -ForegroundColor Green
            } else {
                Write-Host "Site not found: $siteUrl" -ForegroundColor Red
            }
        }
        0 {
            Write-Host "Quitting the script..." -ForegroundColor Red
            disconnect-sposervice
            Start-Sleep 10
        }
        default {
            Write-Host "Invalid option. Please select a valid option (1-4)." -ForegroundColor Red
        }
    }
} while ($option -ne 0)