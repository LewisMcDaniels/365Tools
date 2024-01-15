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
    $user.mailnickname = $upn
}

# Save the changes
Set-ADUser -Instance $user

#Check Change is applied in AD.
Get-ADUser -Identity $DN -Properties msExchHideFromAddressLists

# Sync the change to Office 365
Start-ADSyncSyncCycle -PolicyType Delta

# Wait for 10 seconds
Start-Sleep -Seconds 15

# Check the change has been applied in 365 GAL

# Connect to Office 365
$Credential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

# Check if user is hidden from 365GAL
$User = Get-Mailbox -Identity $upn
if ($User.HiddenFromAddressListsEnabled) {
    Write-Host "User is hidden from the GAL."
} else {
    Write-Host "User is not hidden from the GAL."
}

# Disconnect from Office 365
Remove-PSSession $Session