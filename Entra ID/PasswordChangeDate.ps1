if (-not (Get-Module -Name MSOnline -ListAvailable)) {
    Install-Module -Name MSOnline -Force
}
Import-Module -Name MSOnline -Force
Connect-MsolService

$users = Get-MsolUser | 
Select-Object DisplayName, LastPasswordChangeTimeStamp,@{Name=”PasswordAge”;Expression={(Get-Date)-$_.LastPasswordChangeTimeStamp}} | 
Sort-Object lastpasswordchangetimestamp

$users | Export-Csv -Path "C:\temp\password_changes.csv" -NoTypeInformation

