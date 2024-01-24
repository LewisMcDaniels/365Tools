Install-PackageProvider NuGet 
Set-PSRepository PSGallery -InstallationPolicy Trusted

#Install required modules
if(-not (Get-Module 'Microsoft.Graph.Intune' -ListAvailable)){
    Install-Module 'Microsoft.Graph.Intune' -Scope CurrentUser -Force
    }

if(-not (Get-Module 'AzureAD' -ListAvailable)){
        Install-Module 'AzureAD' -Scope CurrentUser -Force
        }

$OrginalExePol = Get-ExecutionPolicy
if((-not ($OrginalExePol) -ne 'Unrestricted')){
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
}

Import-Module Microsoft.Graph.Intune #import intune module  
Update-MSGraphEnvironment -SchemaVersion beta #set schema version as beta  
Connect-MSGraph  #connect to MS graph
Import-module AzureAD
Connect-AzureAD #Connect AzureAD, to be replaced with MS Graph modules once issues resovled

#Create directories for exports
New-Item -ItemType Directory -Path 'C:\IntuneAuditTool' #Create export folder
$ToplvlFol = 'C:\IntuneAuditTool\' 
New-Item -ItemType Directory -Path "${ToplvlFol}\ScriptsExported"
$ScriptExports = "${ToplvlFol}\ScriptsExported"

#Checks
Write-Host "Listing Intune Managed Devices" -ForegroundColor Green
$IntuneDevices = Get-IntuneManagedDevice |  
ConvertTo-Html -as Table -Property deviceName, id, userprincipalname, complianceState, devicetype, serialNumber, manufacturer, model, operatingSystem, ownertype -Fragment -PreContent "<h2>Intune Managed Devices</h2>"
$IntuneDevicesCSV = Get-IntuneManagedDevice

Write-Host "Listing Device Compliance Policies" -ForegroundColor Green
$CompPolicy = Get-IntuneDeviceCompliancePolicy |
ConvertTo-Html -as List -Property displayname, createdatetime, version -Fragment -PreContent "<h2>Device Compliance Policies</h2>"
$CompPolicyCsv = Get-IntuneDeviceCompliancePolicy 

#Conditional Access Policies
write-host "Listing Conditional Access Policies" -ForegroundColor Green
$CondAccess = Get-AzureADMSConditionalAccessPolicy |
ConvertTo-Html -as Table -Property Displayname,Conditions,State -Fragment -PreContent "<h2>Conditional Access Policies</h2>"
$CondAccessCsv = Get-AzureADMSConditionalAccessPolicy | 
Select-Object Displayname,Conditions,State

#Device Configuration Profiles
write-host "Listing Device Configuration Profiles" -ForegroundColor Green
$DevCongProfiles = get-intunedeviceconfigurationpolicy |
convertto-html -as Table -Property displayname, createdatetime, version -Fragment -PreContent "<h2>Device Configuration Profiles</h2>"
$DevCongProfilesCsv = get-intunedeviceconfigurationpolicy

#List Apps
write-host "Listing mobile apps" -ForegroundColor Green 
$MobApps = get-intunemobileapp | 
ConvertTo-Html -as Table -Property "@odata.type", displayName, Description, publisher, fileName, mobileAppODataType, size -Fragment -PreContent "<h2>Mobile Apps</h2>"
$MobAppsCsv = get-intunemobileapp | 
Select-Object "@odata.type", displayName, Description, publisher, fileName, mobileAppODataType, size

#App Configuration Policies
#write-host "Listing App Configuration Policies" -ForegroundColor Green
#$AppConfig = Get-IntuneAppConfigurationPolicy |

#User & Groups checks
#Much of these commands will be depricated shortly as AzureAD module is being retired in favour of MS Graph, however the relevant modules don't provide usernames
# or UPN, email, or other identifier, only object ID. Once MS Graph modules are updated I'll update this tool.

#Azure AD Group Owners
write-host "Listing Owners of AAD Groups" -ForegroundColor Green
$AADgroups = Get-AzureADGroup -All $true
$GroupOwnersCsv = foreach ($group in $AADgroups) {
    Get-AzureADGroupOwner -ObjectId $group.ObjectId -All $true | ForEach-Object {
            [PsCustomObject]@{
            'Group'     = $group.DisplayName
            'Owner'  = $_.UserPrincipalName
        }
    }
} 

Remove-Variable Group -ErrorAction SilentlyContinue

Start-Sleep -Seconds 10

#Group membership bulk export 
write-host "Exporting Group Membership in bulk to CSV" -ForegroundColor Green
$users = Get-AzureADUser -All $true

$GMEMreport = Foreach ($user in $users) {
  $groups = $user | Get-AzureADUserMembership

  Foreach ($group in $groups) {
    [PSCustomObject][ordered]@{ 
      UserDisplayName   = $user.DisplayName
      UserPrincipalName = $user.UserPrincipalName
      GroupDisplayName  = $group.DisplayName
}}}




#CSS
write-host "Generating HTML report" -ForegroundColor Green
$header = @"
<style>

    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #33FFCE;
        font-size: 28px;

    }

    
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }
    h3 {

        font-family: Arial, Helvetica, sans-serif;
        color: #FF0000;
        font-size: 18px;

    }
    
    h4 {

        font-family: Arial, Helvetica, sans-serif;
        color: ##00FF00;
        font-size: 18px;

    }
    
   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}
	
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }

        #CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #000000;
        font-size: 14px;

    }
    
    
</style>
"@

#Export to HTML
$ScriptBy = "<p id='CreationDate'>Creation Date: $(Get-Date) - Tool created by Flywheel IT Services, Lewis McDaniels</p>"
$ExportPath = "${ToplvlFol}Intune Summary Report.html"
$Report = ConvertTo-HTML -Body "$ScriptBy $IntuneDevices $CompPolicy $CondAccess $MobApps $DevCongProfiles" -Title $ExportPath -Head $header -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date) - Flywheel IT Services, Lewis McDaniels</p>"
$Report | Out-File $ExportPath
Start-Sleep -Seconds 10
Invoke-Item $ExportPath 

#Export to CSV
$IntuneDevicesCSV | Export-Csv -Path "${ToplvlFol}IntuneManagedDevices.Csv"
$CompPolicyCsv | Export-Csv -path "${ToplvlFol}IntuneDeviceCompliancePolicies.Csv"
$MobAppsCsv | Export-Csv -path "${ToplvlFol}IntuneMobileApps.Csv"
$GroupOwnersCsv | Export-Csv -Path "${ToplvlFol}GroupOwners.Csv" -NoTypeInformation
$GMEMreport | Export-csv -path "${ToplvlFol}GroupMemberships.Csv" -NoTypeInformation
$CondAccessCsv | Export-Csv -path "${ToplvlFol}ConditionalAccessPolicies.Csv" -NoTypeInformation
$DevCongProfilesCsv | Export-Csv -path "${ToplvlFol}DeviceConfigurationProfiles.Csv" -NoTypeInformation

#Custom Fuctions to exports

#Export Intune Scripts
Write-Host "Exportings Scripts from Intune Tenant" -ForegroundColor Green
Function Get-DeviceManagementScripts(){

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)][String] $FolderPath,
        [Parameter(Mandatory=$false)][String] $FileName
    )

    $graphApiVersion = "Beta"
    $graphUrl = "https://graph.microsoft.com/$graphApiVersion"

    $result = Invoke-MSGraphRequest -Url "$graphUrl/deviceManagement/deviceManagementScripts" -HttpMethod GET

    if ($FileName){
        $scriptId = $result.value | Select-Object id,fileName | Where-Object -Property fileName -eq $FileName
        $script = Invoke-MSGraphRequest -Url "$graphUrl/deviceManagement/deviceManagementScripts/$($scriptId.id)" -HttpMethod GET
        [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($($script.scriptContent))) | Out-File -Encoding ASCII -FilePath $(Join-Path $FolderPath $($script.fileName))
    }
    else{
        $scriptIds = $result.value | Select-Object id,fileName
        foreach($scriptId in $scriptIds){
            $script = Invoke-MSGraphRequest -Url "$graphUrl/deviceManagement/deviceManagementScripts/$($scriptId.id)" -HttpMethod GET
            [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($($script.scriptContent))) | Out-File -Encoding ASCII -FilePath $(Join-Path $FolderPath $($script.fileName))
        }
    }
}


Get-DeviceManagementScripts -FolderPath "${ScriptExports}"

#Completion 
Write-Host "Checks complete, see output file $Toplvlfol" -ForegroundColor Magenta
Start-Sleep -Seconds 120
Set-ExecutionPolicy -ExecutionPolicy $OrginalExePol -Force
Start-Sleep -Seconds 10 

exit