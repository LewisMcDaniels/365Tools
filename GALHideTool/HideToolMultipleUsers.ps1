# Import the required modules
Import-Module ActiveDirectory
$requiredModules = @("ExchangeOnlineManagement")
$installedModules = Get-InstalledModule | Select-Object -ExpandProperty Name
$missingModules = $requiredModules | Where-Object { $_ -notin $installedModules }

if ($missingModules) {
    Install-Module -Name $missingModules -Force
}

# Connect to Office 365
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

# Get the user's distinguished name (DN)
$upns = Read-Host "Enter the user's UPNs (separated by comma)" # Prompt the user to enter the user's UPNs

$upnList = $upns -split ',' # Split the input into an array of UPNs

$writeHostEntries = @() # Array to store Write-Host entries

foreach ($upn in $upnList) { 
    Write-Host "Processing user: $upn" -ForegroundColor White 
    # Get the user's distinguished name (DN)
    $user = Get-ADUser -Filter {UserPrincipalName -eq $upn} -Properties DistinguishedName
    $DN = $user.DistinguishedName 

    # Get the user object
    $user = Get-ADUser -Identity $DN

    # Hide the user from the GAL
    $user.msExchHideFromAddressLists = $true

    # Check if the mailnickname attribute is empty
    if ([string]::IsNullOrEmpty($user.mailnickname)) {
        # Add the value of the user's UPN to the mailnickname attribute
        write-host "$upn mailnickname attribute is empty, adding UPN to mailnickname attribute" -ForegroundColor Yellow
        $user.mailnickname = $user.UserPrincipalName
    }

    # Save the changes
    Set-ADUser -Instance $user

    # Check changes are applied in AD.
    Write-Host "Checking changes are applied in AD" -ForegroundColor Yellow
    if ($User.msExchHideFromAddressLists -eq $true) {
        Write-Host "$upn User's hide from Exchange attribute is True in Active Directory" -ForegroundColor Green
        $writeHostEntries += "$upn User's hide from Exchange attribute is True in Active Directory"
    } else {
        Write-Host "$upn User's hide from Exchange is False in Active Directory" -ForegroundColor Red
        $writeHostEntries += "$upn User's hide from Exchange is False in Active Directory"
    }

    if ([string]::IsNullOrEmpty($user.mailnickname)) {
        Write-Host " $UPN mailnickname attribute is empty" -ForegroundColor Red
        $writeHostEntries += "$upn mailnickname attribute is empty"
    } else {
        Write-Host "$upn mailnickname attribute is not empty" -ForegroundColor Green
        $writeHostEntries += "$upn mailnickname attribute is not empty"
    }

    # Sync the change to Office 365
    Start-ADSyncSyncCycle -PolicyType Delta

    # Wait for 10 seconds
    Start-Sleep -Seconds 15

    # Check if user is hidden from 365GAL
    $User = Get-Mailbox -Identity $upn
    if ($User.HiddenFromAddressListsEnabled) {
        Write-Host "$UPN is hidden from the 365 GAL." -ForegroundColor Green
        $writeHostEntries += "$upn is hidden from the 365 GAL."
    } else {
        Write-Host "$UPN is not hidden from the 365 GAL." -ForegroundColor Red
        $writeHostEntries += "$upn is not hidden from the 365 GAL."
    }
}

# Disconnect from Office 365
Disconnect-ExchangeOnline -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

# Export Write-Host entries to a text file on the current user's desktop
$writeHostEntries | Out-File -FilePath "$env:USERPROFILE\Desktop\HideToolLog.txt"

