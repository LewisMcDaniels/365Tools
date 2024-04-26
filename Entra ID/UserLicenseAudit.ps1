# Install required modules if not already installed
$requiredModules = @("Microsoft.Graph.users")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force
    }
}

# Import the MS Graph module
Import-Module Microsoft.Graph.users

# Connect to MS Graph
Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

# Get all users with licenses still applied
$LicUsers = Get-MgUser  -All | 
Where-Object {$_.AssignedLicenses.Count -gt 0} | 
Select-Object -Property UserPrincipalName, DisplayName, AssignedLicenses

# Output the disabled users with licenses to a CSV file
Write-Host "Exporting disabled users with licenses to CSV file, see C:\UserLicenseAudit.csv" -ForegroundColor Green
$LicUsers | Export-Csv -Path "C:\UserLicenseAudit.csv" -NoTypeInformation