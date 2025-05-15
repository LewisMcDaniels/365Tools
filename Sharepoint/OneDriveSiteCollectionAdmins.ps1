# Ensure required modules are installed and imported
$modules = @("Microsoft.Graph", "Microsoft.Online.SharePoint.PowerShell")
foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force -Scope CurrentUser
    }
    Import-Module $module -Force
}
# Connect to Microsoft 365 and SharePoint Online
$SPOTenant = Read-Host "Enter your SharePoint Online tenant admin URL (e.g., https://<your-tenant>-admin.sharepoint.com)"
Connect-MgGraph -Scopes "User.Read.All","Sites.Read.All"
Connect-SPOService -Url $SPOTenant

# Get all users with OneDrive provisioned
$users = Get-SPOSite -IncludePersonalSite $true -Limit All | Where-Object { $_.Template -eq "SPSPERS" }

# Prepare output array
$results = @()

foreach ($user in $users) {
    $admins = Get-SPOUser -Site $user.Url | Where-Object { $_.IsSiteAdmin -eq $true }
    foreach ($admin in $admins) {
        $results += [PSCustomObject]@{
            OneDriveUrl = $user.Url
            UserPrincipalName = $user.Owner
            AdminLogin = $admin.LoginName
            AdminEmail = $admin.Email
        }
    }
}

# Export results to CSV
$results | Export-Csv -Path "OneDriveSiteAdmins.csv" -NoTypeInformation

# Disconnect sessions
Disconnect-MgGraph
Disconnect-SPOService