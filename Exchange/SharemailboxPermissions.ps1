# Install required modules
if (-not (Get-Module -Name ExchangeOnlineManagement -ListAvailable)) {
    Install-Module -Name ExchangeOnlineManagement -Force
}

# Connect to Exchange Online
Connect-ExchangeOnline


$permissions = Get-Mailbox -Filter {recipienttypedetails -eq "SharedMailbox"} | Get-Mailboxpermission
Write-Host "Exporting Shared Mailbox Permissions to CSV..." -ForegroundColor Yellow
write-host "This may take a while depending on the number of shared mailboxes in your tenant" -ForegroundColor Yellow
$permissions | Export-Csv -Path "c:\temp\SharedMailboxPermissions.csv" -NoTypeInformation
Write-Host "Export complete" -ForegroundColor Green
Write-Host "path is c:\temp\SharedMailboxPermissions.csv" -ForegroundColor Green