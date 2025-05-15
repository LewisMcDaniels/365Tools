$modules = @('Veeam.Backup.PowerShell')
foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Module $module not found. Installing..."
        Install-Module -Name $module -Force -Scope CurrentUser
    }
    Import-Module $module -ErrorAction Stop
}

$Repos = get-vbrbackuprepository
$RepoDetails = foreach ($repo in $Repos) {
   
        $Name      = $Repo.Name
        $ID        = $Repo.ID
        $Size      = $Repo.GetContainer().CachedTotalSpace.InBytes / 1GB
        $FreeSpace = $Repo.GetContainer().CachedFreeSpace.InBytes / 1GB
     
        [PSCustomObject]@{
            Name        = $Name
            ID          = $ID
            Size        = "{0:N2}" -f $Size
            FreeSpace   = "{0:N2}" -f $FreeSpace
            UsedSpace   = "{0:N2}" -f ($Size - $FreeSpace)
            PercentFree = "{0:P2}" -f ($FreeSpace / $Size)
            PercentUsed = "{0:P2}" -f (($Size - $FreeSpace) / $Size)
        }
    }

$RepoDetails | Format-Table -AutoSize
$outlocation = Read-Host "Enter a location and name for the report file (e.g., C:\temp\RepoReport.csv)"
$RepoDetails | Out-File -FilePath $outlocation -Encoding utf8
$RepoDetails | Export-Csv -Path $outlocation -NoTypeInformation -Encoding utf8
Write-Host "Report saved to $outlocation"
