# Connect to Exchange Online
if (-not (Get-Module -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue)) {
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
}
Import-Module -Name ExchangeOnlineManagement -ErrorAction Stop

Connect-ExchangeOnline

# Get the size of all mailboxes
$Mailboxes = Get-Mailbox -ResultSize Unlimited
$MailboxSizes = @()
foreach ($Mailbox in $Mailboxes) {
    $MailboxSize = Get-MailboxStatistics -Identity $Mailbox.Identity | Select-Object DisplayName, TotalItemSize
    $MailboxSizes += $MailboxSize
}

# Export mailbox sizes to CSV
$MailboxSizes | Export-Csv -Path "C:\Output.csv" -NoTypeInformation
