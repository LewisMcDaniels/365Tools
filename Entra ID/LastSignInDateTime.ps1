$requiredModules = @("Microsoft.Graph.Authentication")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    }
}


Import-Module -Name Microsoft.Graph.Authentication

Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

$users = Get-MgUser -all -Property DisplayName, SignInActivity, AccountEnabled | 
Select-Object DisplayName, AccountEnabled -ExpandProperty SignInActivity | 
select-object Displayname, lastSignInDateTime, AccountEnabled

$users | Export-Csv -Path "C:\LastsigninDataTime.csv" -NoTypeInformation