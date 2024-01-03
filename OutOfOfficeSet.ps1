# Check if required modules are installed
$requiredModules = @("ExchangeOnlineManagement")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -Name $module -ListAvailable)) {
        # Install module if not already installed
        Install-Module -Name $module -Force
    }
}

# Connect to Exchange Online
Connect-ExchangeOnline

# Set out-of-office message for another user
Set-MailboxAutoReplyConfiguration -Identity "user@example.com" -AutoReplyState Enabled -StartTime "7/10/2018 08:00:00" -EndTime "7/15/2018 17:00:00" -ExternalMessage "Out of office message" -InternalMessage "Out of office message"

# Disconnect from Exchange Online
Remove-PSSession $Session

