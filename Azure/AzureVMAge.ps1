# Check if the Azure PowerShell module is installed
if (-not (Get-Module -Name PowerShellGet -ListAvailable)) {
    Install-Module -Name PowerShellGet -AllowClobber -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
} else {
    $latestVersion = (Find-Module -Name PowerShellGet).Version
    $installedVersion = (Get-Module -Name PowerShellGet).Version 

    if ($latestVersion -gt $installedVersion) {
        Update-Module -Name PowerShellGet -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
}

# Check if the Azure PowerShell module is installed and update it if necessary
if (-not (Get-Module -Name Az.Compute -ListAvailable)) {
    Install-Module -Name Az.Compute -AllowClobber -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
} else {
    $latestVersion = (Find-Module -Name Az.Compute).Version
    $installedVersion = (Get-Module -Name Az.Compute).Version

    if ($latestVersion -gt $installedVersion) {
        Update-Module -Name Az.Compute -Force
    }
}

# Import the Azure PowerShell module
Import-Module Az.Compute

# Connect to your Azure account
Connect-AzAccount

# Specify the resource group and virtual machine name
$resourceGroupName = Read-Host -Prompt "Enter the resource group name"
$vmName = Read-Host -Prompt "Enter the virtual machine name"

# Get the virtual machine object
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Get the create date of the virtual machine
$createDate = $vm.TimeCreated

# Calculate the age of the virtual machine
$age = (Get-Date) - $createDate

# Display the create date and age
Write-Host "$vmName Create Date: $createDate"
$ageString = "{0} days, {1} hours, {2} minutes" -f $age.Days, $age.Hours, $age.Minutes
Write-Host "$vmName Age: $ageString"

Read-Host -Prompt "Press Enter to exit"
