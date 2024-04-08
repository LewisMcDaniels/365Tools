$m = Get-Module -Name Microsoft.Graph.Intune -ListAvailable
if (-not $m)
{
    Install-Module NuGet -Force
    Install-Module Microsoft.Graph.Intune
}
Import-Module Microsoft.Graph.Intune -Global



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

Connect-MSGraph | Out-Null
$FolderPath = New-Item -ItemType Directory -Path "C:\temp\IntuneScripts" -Force
Get-DeviceManagementScripts -FolderPath $FolderPath

Write-Host "Exported Intune Scripts to $FolderPath" -ForegroundColor Green

