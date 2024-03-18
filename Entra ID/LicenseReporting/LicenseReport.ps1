# Connect to Microsoft Graph API
Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

# Import the required module
Import-Module -Name Microsoft.Graph.Authentication

$users = Get-MgUser -all -Property DisplayName, SignInActivity, AccountEnabled | 
Select-Object DisplayName, AccountEnabled -ExpandProperty SignInActivity | 
select-object Displayname, lastSignInDateTime, AccountEnabled

$users | Export-Csv -Path "C:\output3.csv" -NoTypeInformation