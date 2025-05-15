if (-not (Get-Module -ListAvailable -Name Veeam.Archiver.PowerShell)) {
    Install-Module -Name Veeam.Archiver.PowerShell -Force -Scope CurrentUser
}
Import-Module Veeam.Archiver.PowerShell

# Get all organizations
$orgs = Get-VBOOrganization

$results = foreach ($org in $orgs) {
    $jobs = Get-VBOJob -Organization $org
    if ($jobs) {
        foreach ($job in $jobs) {
            [PSCustomObject]@{
                OrganizationName = $org.Name
                JobName          = $job.Name
                IsEnabled        = $job.IsEnabled
            }
        }
    } else {
        [PSCustomObject]@{
            OrganizationName = $org.Name
            JobName          = "<No Jobs>"
            IsEnabled        = $null
        }
    }
}

$export = $results

$outfile = Read-Host "Enter a location and name for the report file (e.g., C:\temp\Veeam365_OrgReport.csv)"
$export | Export-Csv -Path $outfile -NoTypeInformation
Write-Host "Report saved to $outfile"
$export | Format-Table -AutoSize