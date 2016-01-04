param (
    [string] 
    $ServiceName = $(throw "-$ServiceName is required."),
    
	[bool]
	$IncludeConfiguration = $false
   
 )


$stageSlotFound = $Null -ne (Get-AzureDeployment -ServiceName $ServiceName -ErrorAction SilentlyContinue -Slot Staging)
$prodSlotFound = $Null -ne (Get-AzureDeployment -ServiceName $ServiceName -ErrorAction SilentlyContinue -Slot Production)

if ($stageSlotFound -and $prodSlotFound) 
{   
    if ($IncludeConfiguration)
    {
	    $tmpStagingCscfg = "$env:TEMP\$serviceName.staging.cscfg" 
        $tmpProductionCsCfg = "$env:TEMP\$ServiceName.production.cscfg"

        Write-Host "Downloading Slot Configurations...$(Get-Date)"

        Get-AzureDeployment -ServiceName $ServiceName -Slot Production | Select -ExpandProperty Configuration > $tmpProductionCsCfg
        Get-AzureDeployment -ServiceName $ServiceName -Slot Staging | Select -ExpandProperty Configuration > $tmpStagingCscfg

        Write-Host "Swapping VIP...$(Get-Date)"
        
        Move-AzureDeployment -ServiceName $ServiceName 

        Write-Host "Swapping Configurations...$(Get-Date)"

        $productionConfigTask = { Set-AzureDeployment -ServiceName $args[0] -Slot Production -Config -Configuration $args[1] -Verbose -ErrorAction SilentlyContinue }
        $stagingConfigTask = { Set-AzureDeployment -ServiceName $args[0] -Slot Staging -Config -Configuration  $args[1] -Verbose -ErrorAction SilentlyContinue }

        $stagingConfigJob = Start-Job -ScriptBlock $stagingConfigTask -ArgumentList $ServiceName,$tmpProductionCsCfg
        $productionConfigJob = Start-Job -ScriptBlock $productionConfigTask -ArgumentList $ServiceName,$tmpStagingCscfg

        Wait-Job -Job $stagingConfigJob, $productionConfigJob -Verbose

        Write-Host "Jobs Complete...$(Get-Date)"

        $stagingConfigJobResults = Receive-Job -Job $stagingConfigJob -Wait
        $productionConfigJobResults = Receive-Job -Job $productionConfigJob -Wait

        $stagingConfigJobResults
        $productionConfigJobResults
        
        Write-Host "Deleting Temporary Files...$(Get-Date)"

        Remove-Item $tmpStagingCscfg -Force -ErrorAction SilentlyContinue
        Remove-Item $tmpProductionCsCfg -Force -ErrorAction SilentlyContinue

    }
    else 
    {
		Write-Host "Swapping VIP...$(Get-Date)"

        Move-AzureDeployment -ServiceName $ServiceName -Verbose
    }

}else 
{
    Write-Error "Deployments not available in all slots.  Cannot swap." -Category InvalidOperation
}