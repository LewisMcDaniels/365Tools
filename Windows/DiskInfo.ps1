# Get information on each disk and network drive
$drives = Get-PSDrive -PSProvider FileSystem

# Create an array to store the drive information
$driveInfo = @()

foreach ($drive in $drives) {
    $usedSpace = [math]::round(($drive.Used / 1GB), 2)
    $freeSpace = [math]::round(($drive.Free / 1GB), 2)
    $totalSpace = [math]::round(($drive.Used + $drive.Free) / 1GB, 2)
    $connectionType = if ($drive.DisplayRoot -like "\\*") { "Network Drive" } else { "Local Disk" }

    $driveInfo += [PSCustomObject]@{
        Name           = $drive.Name
        UsedSpaceGB    = $usedSpace
        FreeSpaceGB    = $freeSpace
        TotalSpaceGB   = $totalSpace
        ConnectionType = $connectionType
    }
}

# Output the drive information
$driveInfo | Format-Table -AutoSize

$exportOption = Read-Host "Press 1 to export the information to a CSV file or Q to quit"

if ($exportOption -eq '1') {
    $csvPath = Read-Host "Enter the path where you want to save the CSV file"
    $driveInfo | Export-Csv -Path $csvPath -NoTypeInformation
    Write-Host "Drive information exported to $csvPath"
} elseif ($exportOption -eq 'Q' -or $exportOption -eq 'q') {
    Write-Host "Exiting without exporting."
} else {
    Write-Host "Invalid option. Exiting without exporting."
}