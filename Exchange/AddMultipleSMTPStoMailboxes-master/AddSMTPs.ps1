# Install required modules
if (-not (Get-Module -Name ExchangeOnlineManagement -ListAvailable)) {
    Install-Module -Name ExchangeOnlineManagement -Force
}

# Connect to Exchange Online
Connect-ExchangeOnline


# One csv for each domain, easier and cleaner
# Use template.csv to create your own csv files.
$SMTP1 = "C:\Scripts\Domain1.csv"
$SMTP2 = "C:\Scripts\Domain2.csv"
$SMTP3 = "C:\Scripts\Domain3.csv"
$SMTP4 = "C:\Scripts\Domain4.csv"


#Import from CSV
Import-CSV $SMTP1 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}
Import-CSV $SMTP2 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}
Import-CSV $SMTP3 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}
Import-CSV $SMTP4 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}

