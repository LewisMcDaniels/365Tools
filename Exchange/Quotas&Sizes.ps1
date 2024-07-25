# Connect to Exchange Online
if (-not (Get-Module -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue)) {
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
}
Import-Module -Name ExchangeOnlineManagement -ErrorAction Stop

Connect-ExchangeOnline


# Get mailbox sizes and quotas
$Mailboxes = Get-Mailbox -ResultSize Unlimited
$MailboxSizes = $Mailboxes | Get-MailboxStatistics | Select-Object DisplayName, TotalItemSize
$MailboxQuotas = $Mailboxes | Get-Mailbox | Select-Object DisplayName, IssueWarningQuota, ProhibitSendQuota, ProhibitSendReceiveQuota

# Display mailbox sizes and quotas
$MailboxSizes
$MailboxQuotas

# Disconnect from Exchange Online
Remove-PSSession $ExchangeSession
# Export mailbox sizes and quotas to CSV file
$MailboxSizes | Export-Csv -Path "MailboxSizes.csv" -NoTypeInformation
$MailboxQuotas | Export-Csv -Path "MailboxQuotas.csv" -NoTypeInformation