# Import the Active Directory module
Import-Module ActiveDirectory

# Path to the CSV file
$csvPath = Read-Host "Enter the path to the CSV file with the list of users to be disabled"

# Import the CSV file
$users = Import-Csv -Path $csvPath

# Loop through each user in the CSV file
foreach ($user in $users) {
    # Get the user from Active Directory
    $adUser = Get-ADUser -Identity $user.Username

    # Disable the user
    Disable-ADAccount -Identity $adUser
}

Write-Host "All users listed in the CSV file have been disabled."