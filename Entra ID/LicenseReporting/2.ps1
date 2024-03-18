# Connect to Microsoft Graph API
Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

# Import the required module
Import-Module -Name Microsoft.Graph.Authentication

# Create a hash table that maps SKU IDs to license names
$licenseNames = @{
    "6fd2c87f-b296-42f0-b197-1e91e994b900" = "Office 365 E1"
    "18181a46-0d4e-45cd-891e-60aabd171b4e" = "Office 365 E3"
    "05e9a617-0261-4cee-bb44-138d3ef5d965" = "MICROSOFT 365 E3"
    "8f0c5670-4e56-4892-b06d-91c085d7004f" = "APP CONNECT IW"
    

    # Add more SKU IDs and names as needed
}

$users = Get-MgUser -all -Property DisplayName, AccountEnabled, AssignedLicenses | 
    Select-Object DisplayName, AccountEnabled, @{Name="AssignedLicenses"; Expression={($_.AssignedLicenses | ForEach-Object { $licenseNames[$_.SkuId] }) -join ", "}}

# Export the information to CSV
$users | Export-Csv -Path "C:\output.csv" -NoTypeInformation