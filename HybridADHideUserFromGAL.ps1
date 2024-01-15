# Import the Active Directory module
Import-Module ActiveDirectory

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

Get-ADUser -Identity $DN -Properties msExchHideFromAddressLists

