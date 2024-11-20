$requiredModules = @("Microsoft.Graph")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    }
}

Import-Module -Name Microsoft.Graph.Authentication, Microsoft.Graph.users

Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

$users = Get-MgUser -all -Property DisplayName, SignInActivity, AccountEnabled, UserType | 
    Select-Object DisplayName, AccountEnabled, UserType -ExpandProperty SignInActivity | 
    Select-Object Displayname, lastSignInDateTime, LastNonInteractiveSignInDateTime, AccountEnabled, UserType

$users | Export-Csv -Path "C:\LastSigninTimes.csv" -NoTypeInformation
Write-Host "Exported to C:\LastSigninTimes.csv"