# Ensure the Microsoft.Graph module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
    Install-Module -Name Microsoft.Graph.Users -Force -Scope CurrentUser
}


$ErrorActionPreference = 'SilentlyContinue'

# Import the Microsoft Graph Users PowerShell module
Import-Module Microsoft.Graph.Users

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"  -NoWelcome

# Display the tenant name
$tenantDetails = Get-MgOrganization
$tenantName = $tenantDetails.DisplayName
Write-Host "Connected to tenant: $tenantName" -ForegroundColor Green


# Function to get a valid CSV path
function Get-ValidCsvPath {
    param (
        [string]$promptMessage
    )
    do {
        $csvPath = Read-Host -Prompt $promptMessage
        if (-Not (Test-Path -Path $csvPath -PathType Leaf)) {
            Write-Host "The file path is invalid or the file does not exist. Please try again." -ForegroundColor Red
        }
    } until (Test-Path -Path $csvPath -PathType Leaf)
    return $csvPath
}

# Get the valid CSV path from the user
$csvPath = Get-ValidCsvPath -promptMessage "Please enter the path to your CSV file"

# Import the CSV file
$users = Import-Csv -Path $csvPath

Write-Host "Loading options" -ForegroundColor Green
Write-Host

# Provide options to the user
do {
Write-Host "Select an option:"
Write-Host "1. Disable each user in the CSV list"
Write-Host "2. Check the disabled status of each user in the CSV list"
Write-Host "3. Enable each user in the CSV list"
Write-Host "4. Quit"
$option = Read-Host -Prompt "Enter the number of your choice"

switch ($option) {
    1 {
        Write-Host "Disabling each user in the CSV list..." -ForegroundColor Yellow
        foreach ($user in $users) {
            $userPrincipalName = $user.UserPrincipalName
            Update-MgUser -UserId $userPrincipalName -AccountEnabled:$false
            Write-Output "Disabling user: $userPrincipalName"
        }
    }
    2 {
        $users = Import-Csv -Path $csvPath
        Write-Host "Checking the current account status of each user in the CSV list..." -ForegroundColor Yellow
        foreach ($user in $users) {
            $userPrincipalName = $user.UserPrincipalName
            $userDetails = Get-MgUser -UserId $userPrincipalName -Property UserPrincipalName, AccountEnabled | Select-Object UserPrincipalName, AccountEnabled
            Write-Output "User: $($userDetails.UserPrincipalName) - Account Enabled: $($userDetails.AccountEnabled)"
        }
    }
    3 {
        Write-Host "Enabling each user in the CSV list..." -ForegroundColor Yellow
        foreach ($user in $users) {
            $userPrincipalName = $user.UserPrincipalName
            Update-MgUser -UserId $userPrincipalName -AccountEnabled:$true
            Write-Output "Enabling user: $userPrincipalName"
        }

    }
    4 {
        Write-Host "Quitting the script..." -ForegroundColor Yellow
        Disconnect-Graph | Out-Null
        break
    }
    default {
        Write-Host "Invalid option selected. Please try again." -ForegroundColor Red
    }
}
} while ($option -ne 4)



# Disconnect from Microsoft Graph
Write-Host "Disconnecting from Microsoft Graph..." -ForegroundColor Yellow
Disconnect-MgGraph | Out-Null