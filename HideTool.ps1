# Import the required modules
Import-Module ActiveDirectory
$requiredModules = @("ExchangeOnlineManagement")
$installedModules = Get-InstalledModule | Select-Object -ExpandProperty Name
$missingModules = $requiredModules | Where-Object { $_ -notin $installedModules }

if ($missingModules) {
    Install-Module -Name $missingModules -Force
}

# Get the user's distinguished name (DN)

$upn = Read-Host "Enter the user's UPN" # Prompt the user to enter the user's UPN
$user = Get-ADUser -Filter {UserPrincipalName -eq $upn} -Properties DistinguishedName
$DN = $user.DistinguishedName 

# Get the user object
$user = Get-ADUser -Identity $DN

# Hide the user from the GAL
$user.msExchHideFromAddressLists = $true

# Check if the mailnickname attribute is empty
if ([string]::IsNullOrEmpty($user.mailnickname)) {
    # Add the value of the user's UPN to the mailnickname attribute
    write-host "mailnickname attribute is empty, adding UPN to mailnickname attribute" -ForegroundColor Yellow
    $user.mailnickname = $user.UserPrincipalName
}

# Save the changes
Set-ADUser -Instance $user

#Check changes are applied in AD.
Write-Host "Checking changes are applied in AD" -ForegroundColor Yellow
if ($User.msExchHideFromAddressLists -eq $true) {
    Write-Host "Users hide from Exchange attribute is True in Active Directory" -ForegroundColor Green
} else {
    Write-Host "Users hide from Exchange is False in Active" -ForegroundColor Red
}

if ([string]::IsNullOrEmpty($user.mailnickname)) {
    Write-Host "mailnickname attribute is empty" -ForegroundColor Red
} else {
    Write-Host "mailnickname attribute is not empty" -ForegroundColor Green
}

# Sync the change to Office 365
Start-ADSyncSyncCycle -PolicyType Delta

# Wait for 10 seconds
Start-Sleep -Seconds 15

# Check the change has been applied in 365 GAL

# Connect to Office 365
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

# Check if user is hidden from 365GAL
$User = Get-Mailbox -Identity $upn
if ($User.HiddenFromAddressListsEnabled) {
    Write-Host "User is hidden from the GAL." -ForegroundColor Green
} else {
    Write-Host "User is not hidden from the GAL." -ForegroundColor Red
}

# Disconnect from Office 365
Disconnect-ExchangeOnline -ErrorAction SilentlyContinue -WarningAction SilentlyContinue