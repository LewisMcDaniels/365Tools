$moduleName = "MSOnline"

# Check if the module is already installed
if (-not (Get-Module -Name $moduleName -ListAvailable)) {
    # Install the module
    Install-Module -Name $moduleName -Force
} else {
    # Update the module to the latest version
    Update-Module -Name $moduleName -Force
}

# Import the module
Import-Module -Name $moduleName -Force

Connect-MsolService

$users = Get-MsolUser -All

$output = foreach ($user in $users) {
    if ($user.StrongAuthenticationMethods -ne $null) {
        $mfaEnabled = $false
        $methodTypes = [System.Collections.ArrayList]::new()

        foreach ($method in $user.StrongAuthenticationMethods) {
            $methodTypes.Add($method.MethodType)
            $mfaEnabled = $true
        }

        [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            Country = $user.Country
            SMS = $methodTypes.Contains("OneWaySMS")
            PhoneAppOTP = $methodTypes.Contains("PhoneAppOTP")
            PhoneAppNotification = $methodTypes.Contains("PhoneAppNotification")
            PhoneAppPassword = $methodTypes.Contains("PhoneAppPassword")
            EmailOTP = $methodTypes.Contains("EmailOTP")
            EmailVerified = $methodTypes.Contains("EmailVerified")
            MFAEnabled = $mfaEnabled
        }
    } else {
        [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            Country = $user.Country
            SMS = $false
            PhoneAppOTP = $false
            PhoneAppNotification = $false
            PhoneAppPassword = $false
            EmailOTP = $false
            EmailVerified = $false
            MFAEnabled = $false
        }
    }
}

$output | Sort-Object -Property UserPrincipalName | Select-Object UserPrincipalName, Country, SMS, PhoneAppOTP, PhoneAppNotification, PhoneAppPassword, EmailOTP, EmailVerified, MFAEnabled | Export-Csv -Path "C:\MFAReportOutput.csv" -NoTypeInformation 