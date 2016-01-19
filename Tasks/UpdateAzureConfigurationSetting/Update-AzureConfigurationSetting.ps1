<# 
 .Synopsis
  Updates settings of a live service.  Found most of this at http://dzimchuk.net/post/updating-azure-cloud-service-configuration-with-powershell
  Just modified it a bit for using in VSO RM/Build

 .Parameter ServiceName
  Name of a cloud service

 .Parameter slot
  Deployment slot

 .Parameter settingKey
  Key of a setting to be updated

 .Parameter settingValue
  Setting value to be set
 
 .Example
   # Update TestSetting value in the staging deployment of AzureSettingsUpdateSample service
   Update-Setting.ps1 -ServiceName AzureSettingsUpdateSample 
                      -Slot Staging 
                      -SettingKey TestSetting 
                      -SettingValue 'updated value'
#>

param (
    [string] 
    $ServiceName = $(throw "-ServiceName is required."),
    
    [string]
    [ValidateSet('Production','Staging')]
    $Slot = $(throw "-Slot is required."),

    [string] 
    $SettingKey = $(throw "-SettingKey is required."),

    [string] 
    $SettingValue = $(throw "-SettingValue is required.")
 )

function UpdateSettingInRoles([xml]$configuration, [string]$setting, [string]$value)
{
    $updated = $false

    $configuration.ServiceConfiguration.Role | % { 
            $settingElement = $_.ConfigurationSettings.Setting | ? { $_.name -eq $setting }
            if ($settingElement -ne $null -and $settingElement.value -ne $value)
            {
                $settingElement.value = $value
                $updated = $true
            }
        }
        
    return $updated
}

Write-Host "Updating setting $SettingKey for $ServiceName" -ForegroundColor Green

# get current settings from Azure
$deployment = Get-AzureDeployment -ServiceName $ServiceName -Slot $Slot -ErrorAction SilentlyContinue -ErrorVariable $deploymentErrorVariable


if ($deploymentErrorVariable){
    Write-Warning "Warning - Error when getting deployment.  $deploymentErrorVariable"   
}

if ($deployment)
{
    $configuration = [xml]$deployment.Configuration

    # update setting if needed
    $updated = UpdateSettingInRoles $configuration $SettingKey $SettingValue

    if (-not($updated))
    {
        Write-Host "No settings have been updated as they are either up to date or not found"
        return
    }

    # save as a temporary file and upload settings to Azure
    $filename = $env:temp + "\" + $ServiceName + ".cscfg"
    $configuration.Save("$filename")

    Set-AzureDeployment -Config -ServiceName $ServiceName -Configuration "$filename" -Slot $Slot

    Remove-Item ("$filename")
}else {
    Write-Warning "No deployment was found.  Skipping configuration setting update..."
    
}
Write-Host "Done"
