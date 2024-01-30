# Install required modules if missing
$requiredModules = @("AzureAD")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    }
}

# Import the AzureAD module
Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD

# Get all users
$users = Get-AzureADUser -All $true

# Create an empty array to store the user data
$userData = @()

# Iterate through each user
foreach ($user in $users) {
    # Get the user's UPN, Country, and MFA status
    $upn = $user.UserPrincipalName
    $country = $user.Country
    $mfaStatus = $user.StrongAuthenticationMethods.Count -gt 0

    # Create a custom object with the user data
    $userObject = [PSCustomObject]@{
        UPN = $upn
        Country = $country
        MFAStatus = $mfaStatus
    }

    # Add the user object to the array
    $userData += $userObject
}

# Export the user data to a CSV file
$userData | Export-Csv -Path "$PSScriptRoot\Report.csv" -NoTypeInformation