# Install required modules if not already installed
$requiredModules = @("Microsoft.Graph.users")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force
    }
}

Import-Module Microsoft.Graph.Users

# Specify the folder path where the user photos will be saved
$PhotoLocation = Read-Host "Enter the path to the directory containing the photos"

# Connect with privileges
Connect-MgGraph -Scopes "User.ReadWrite.All" -NoWelcome

if (!(Test-Path ($PhotoLocation))) {
    Write-Host "Can't find $PhotoLocation - Double check the user photos folder path"; break
}
$i = 0

# Get all Entra ID accounts
$Users = Get-MgUser -All

$ProgDelta = 100 / ($Users.Count); $CheckCount = 0; $UserNumber = 0
ForEach ($User in $Users) {
    $UserNumber++
    $UserStatus = $User.DisplayName + " [" + $UserNumber + "/" + $Users.Count + "]"
    Write-Progress -Activity "Updating photo for" -Status $UserStatus -PercentComplete $CheckCount
    $CheckCount += $ProgDelta
    $FullName = $User.GivenName + "." + $User.Surname
    $UserPhoto = $PhotoLocation + "\" + $FullName 
    $UserPhotoExtensions = @(".png", ".jpg", ".jpeg", ".bmp")
    $UserPhotoPath = $UserPhotoExtensions | Where-Object { Test-Path ($UserPhoto + $_) } | Select-Object -First 1
    if ($UserPhotoPath) {
        # Update the photo
        Write-Host "Updating photo for" $FullName -ForegroundColor Green
        Set-MgUserPhotoContent -UserId $User.Id -Infile ($UserPhoto + $UserPhotoPath)
        $i++
    }
    else {
        Write-Host "No photo available for" $FullName
    }
}