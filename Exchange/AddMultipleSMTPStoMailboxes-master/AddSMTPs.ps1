Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName Bittitan@williammartin.onmicrosoft.com

#One csv for each domain, easier and cleaner
$SMTP1 = "C:\Scripts\cedrec.csv"
$SMTP2 = "C:\Scripts\environmentalcouk.csv"
$SMTP3 = "C:\Scripts\healthandsafetycouk.csv"
$SMTP4 = "C:\Scripts\cedreccouk.csv"
$SMTP5 = "C:\Scripts\cedreceu.csv"
$SMTP6 = "C:\Scripts\cedrecinfo.csv"
$SMTP7 = "C:\Scripts\cedrecnet.csv"
$SMTP8 = "C:\Scripts\barbourehscom.csv"

#Import from CSV
Import-CSV $SMTP1 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}
Import-CSV $SMTP2 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}
Import-CSV $SMTP3 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}
Import-CSV $SMTP4 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}
Import-CSV $SMTP5 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}
Import-CSV $SMTP6 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}
Import-CSV $SMTP7 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}
Import-CSV $SMTP8 | ForEach-Object {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}
