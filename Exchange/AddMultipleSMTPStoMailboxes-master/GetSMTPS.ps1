# Install required modules
if (-not (Get-Module -Name ExchangeOnlineManagement -ListAvailable)) {
    Install-Module -Name ExchangeOnlineManagement -Force
}

# Connect to Exchange Online
Connect-ExchangeOnline



$Users = "C:\scripts\users.csv"
Import-CSV $Users| ForEach-Object {Get-Mailbox -Identity $_.Users | Select-Object Alias,@{Name=”EmailAddresses”;Expression={$_.EmailAddresses |Where-Object {$_ -LIKE “SMTP:*”}}}} | Format-List




