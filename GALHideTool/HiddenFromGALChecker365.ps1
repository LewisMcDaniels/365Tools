# Install required modules if not already installed
$requiredModules = @("ExchangeOnlineManagement")
$installedModules = Get-InstalledModule | Select-Object -ExpandProperty Name
$missingModules = $requiredModules | Where-Object { $_ -notin $installedModules }

if ($missingModules) {
    Install-Module -Name $missingModules -Force
}

# Connect to Office 365
$Credential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

# Check if user is hidden from GAL
$UserPrincipalName = Read-Host "Enter the user's UPN" # Prompt the user to enter the user's UPN
$User = Get-Mailbox -Identity $UserPrincipalName
if ($User.HiddenFromAddressListsEnabled) {
    Write-Host "User is hidden from the GAL."
} else {
    Write-Host "User is not hidden from the GAL."
}

# Disconnect from Office 365
Remove-PSSession $Session