
install-module -name msonline
Import-Module MSOnline
Connect-MsolService
# BEGIN: Get user licenses
$users = Get-MsolUser -All
foreach ($user in $users) {
    $licenses = $user.Licenses.AccountSkuId

    Write-Host "User: $($user.UserPrincipalName)"
    Write-Host "Licenses: $($licenses -join ', ')"
    Write-Host
}