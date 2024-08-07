$requiredModules = @("Microsoft.Graph")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    }
}

Import-Module -Name Microsoft.Graph.Authentication

Connect-MgGraph -Scopes "User.Read.All" -NoWelcome

$users = Get-MgUser -all -Property DisplayName, SignInActivity, AccountEnabled, UserType | 
    Select-Object DisplayName, AccountEnabled, UserType -ExpandProperty SignInActivity | 
    Select-Object Displayname, lastSignInDateTime, LastNonInteractiveSignInDateTime, AccountEnabled, UserType

$users | Export-Csv -Path "C:\LastsigninDataTime3.csv" -NoTypeInformation