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
$csvPath = Read-Host "Enter the path to the CSV file" # Prompt the user to enter the path to the CSV file
$csvData = Import-Csv -Path "$csvPath" # Import the CSV file

$writeHostEntries = @() # Array to store Write-Host entries

foreach ($row in $csvData) { 
    $upn = $row.UPN # Get the UPN from the CSV row
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
    else {
        # Add the value of the user's UPN to the mailnickname attribute
        write-host "$upn mailnickname attribute is not empty" -ForegroundColor Yellow
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

    
}

# Sync the change to Office 365
write-host "Syncing the change to 365" -ForegroundColor White
Start-ADSyncSyncCycle -PolicyType Delta

# Count the number of rows in the imported CSV
$rowCount = $csvData.Count

# Wait for the counted number of rows in seconds multiplied by 20
Start-Sleep -Seconds ($rowCount * 20)

$writeHostEntries = @() # Array to store Write-Host entries

# Check if user is hidden from 365GAL
write-host "Checking if user is hidden from the Exchange Online GAL" -ForegroundColor White
foreach ($row in $csvData) { 
    $upn = $row.UPN
    $user = Get-Mailbox -Identity $upn
    if ($user.HiddenFromAddressListsEnabled) {
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
New-Item -Path $env:USERPROFILE\Desktop\HideToolLog.txt -ItemType File -Force
$writeHostEntries | Out-File -FilePath $env:USERPROFILE\Desktop\HideToolLog.txt -Append