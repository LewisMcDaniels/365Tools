# Import the Active Directory module
Import-Module ActiveDirectory

# Get the user's distinguished name (DN)

$upn = "user@example.com"
$user = Get-ADUser -Filter {UserPrincipalName -eq $upn} -Properties DistinguishedName
$DN = $user.DistinguishedName 

# Get the user object
$user = Get-ADUser -Identity $DN

# Hide the user from the GAL
$user.msExchHideFromAddressLists = $true

# Save the changes
Set-ADUser -Instance $user



