$requiredModules = @("Microsoft.Graph")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    }
}

Import-Module -Name Microsoft.Graph.Authentication, Microsoft.Graph.users

Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

$users = Get-MgUser -Filter "userType eq 'Guest'" -Property DisplayName, Mail, SignInActivity, AccountEnabled, UserType | 
    Select-Object DisplayName, Mail, AccountEnabled, UserType -ExpandProperty SignInActivity | 
    Select-Object Displayname, Mail, lastSignInDateTime, LastNonInteractiveSignInDateTime, AccountEnabled, UserType

$users | Export-Csv -Path "C:\GuestLastSigninTimes.csv" -NoTypeInformation