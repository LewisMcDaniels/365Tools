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

# Get all disabled users with licenses still applied
$disabledUsers = Get-MgUser -Filter "accountEnabled eq false" -All | 
Where-Object {$_.AssignedLicenses.Count -gt 0} | 
Select-Object -Property UserPrincipalName, DisplayName, AssignedLicenses

# Output the disabled users with licenses to a CSV file
Write-Host "Exporting disabled users with licenses to CSV file, see C:\DisabledUsersWithLicenses.csv" -ForegroundColor Green
$disabledUsers | Export-Csv -Path "C:\DisabledUsersWithLicenses.csv" -NoTypeInformation
