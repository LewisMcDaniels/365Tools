## Get all AD Groups
$Groups = Get-ADGroup -Filter * -Properties * | 
Select-Object Name,Description,GroupCategory,GroupScope,DistinguishedName | 
Sort-Object Name
#Export CSV
Write-host "Exporting to .CSV file" -ForegroundColor Green
$CSVPath = ".\$env:computername AD Groups.csv"
$Groups | Export-CSV $CSVPath