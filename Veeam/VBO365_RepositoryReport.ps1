# Import and install required modules
$moduleName = "Veeam.Archiver.PowerShell"
if (-not (Get-Module -ListAvailable -Name $moduleName)) {
    Install-Module -Name $moduleName -Scope CurrentUser -Force
}
Import-Module $moduleName -ErrorAction Stop

$repositories = Get-VBORepository

$report = foreach ($repo in $repositories) {
    [PSCustomObject]@{
    Name                = $repo.Name
    Description         = $repo.Description
    Path                = $repo.Path
    FreeSpaceGB         = [math]::Round($repo.FreeSpace / 1GB, 2)
    CapacityGB          = [math]::Round($repo.Capacity / 1GB, 2)
    RepositoryID        = $repo.Id
    }
}

$report | Format-Table -AutoSize
$outfile = Read-Host "Enter a location and name for the report file (e.g., C:\temp\Veeam365_RepoReport.csv)"
$report | Export-Csv -Path $outfile -NoTypeInformation
Write-Host "Report saved to $outfile"
