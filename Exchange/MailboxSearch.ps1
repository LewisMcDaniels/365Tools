# Install required modules if missing
$requiredModules = "ExchangeOnlineManagement"
$missingModules = $requiredModules | Where-Object { -not (Get-Module -ListAvailable -Name $_) }
if ($missingModules) {
    Write-Host "Installing missing modules: $missingModules"
    Install-Module -Name $missingModules -Force -AllowClobber
}

# Import the module
Import-Module -Name ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline

# List all mailboxes
$Username = Read-Host "Enter the username"
$mailbox = Get-Mailbox -Identity $Username
$mailboxstats = Get-MailboxStatistics -Identity $Username

Write-Host "Mailbox: $($mailbox.DisplayName)" -ForegroundColor Green
Write-Host "Mailbox Size: $($mailboxstats.TotalItemSize)" -ForegroundColor Cyan
Write-Host "Mailbox Item Count: $($mailboxstats.ItemCount)" -ForegroundColor Blue
Write-Host "Mailbox Last Logon: $($mailboxstats.LastLogonTime)" -ForegroundColor DarkGreen
