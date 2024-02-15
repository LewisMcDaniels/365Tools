# Install module if needed
$moduleName = "ExchangeOnlineManagement"
if (-not (Get-Module -ListAvailable -Name $moduleName)) {
    Install-Module -Name $moduleName -Force
}

# Connect to Exchange Online
Connect-ExchangeOnline

# Get mailbox retention policy 
$Mailbox = Read-Host -Prompt "Enter mailbox name"
$RetentionPolicy = Get-Mailbox $Mailbox | Select-Object -ExpandProperty RetentionPolicy
$ArchiveStatus = Get-Mailbox $Mailbox | Select-Object -ExpandProperty ArchiveStatus
$RetentionPolicySettings = Get-RetentionPolicy $RetentionPolicy

# Check if retention policy is applied
if ($RetentionPolicy) {
    Write-Output "Retention policy '$($RetentionPolicy)' is applied to mailbox '$Mailbox'."
    # Display retention policy settings
    $RetentionPolicySettings
} else {
    Write-Output "No retention policy is applied to mailbox '$Mailbox'."

    
}

# Check if archiving is enabled
if ($ArchiveStatus -eq "Active") {
    Write-Output "Archiving is enabled on mailbox '$Mailbox'."
} else {
    Write-Output "Archiving is not enabled on mailbox '$Mailbox'."
}



