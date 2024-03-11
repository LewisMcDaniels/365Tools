# Install the required modules if not already installed
$requiredModules = @("Microsoft.Graph.Authentication")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force
    }
}
# Import the module
Import-Module -Name Microsoft.Graph.Authentication

# Connect to Microsoft Graph API
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All" -noWelcome
# Get all disabled users
$disabledUsers = Get-MgUser -Filter "accountEnabled eq false"

# Create an empty array to store the results
$results = @()

# Iterate through each disabled user
foreach ($user in $disabledUsers) {
    # Get the user's group memberships
    $groupMemberships = Get-MgUserMemberOf -UserId $user.Id

    # Iterate through each group membership
    foreach ($group in $groupMemberships) {
        # Get the group details
        $groupDetails = Get-MgGroup -GroupId $group.Id

        # Create a custom object with user and group details
        $result = [PSCustomObject]@{
            User = $user.DisplayName
            Group = $groupDetails.DisplayName
        }

        # Add the result to the array
        $results += $result
    }
}

# Export the results to a CSV file
$exploc = "C:\DisabledUsersGroupMembership.csv"
Write-Host "Exporting results to $exploc" -ForegroundColor Green -BackgroundColor Black
$results | Export-Csv -Path $exploc -NoTypeInformation

