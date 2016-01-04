param (
    [string] 
    $ServiceName = $(throw "-$ServiceName is required."),
    
	[string]
	$IncludeConfiguration = $false,
    
    [string]
    $RemoveStagingDeploymentSlot = $false
   
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

        if ($RemoveStagingDeploymentSlot)
        {
            $stagingConfigJob = Start-Job -ScriptBlock { Write-Host "Skipping update of Staging slot since it is scheduled for deletion..." } # Do nothing since we're deleting it.  This is really just to not have a bunch of other if statements to make the delete deployment slot task run faster.  (By not performing an unncessary config update to a slot you're going to delete)
            $productionConfigJob = Start-Job -ScriptBlock $productionConfigTask -ArgumentList $ServiceName,$tmpStagingCscfg    
        }
        else 
        {
            $stagingConfigJob = Start-Job -ScriptBlock $stagingConfigTask -ArgumentList $ServiceName,$tmpProductionCsCfg        
            $productionConfigJob = Start-Job -ScriptBlock $productionConfigTask -ArgumentList $ServiceName,$tmpStagingCscfg
        }
        
        Wait-Job -Job $stagingConfigJob, $productionConfigJob -Verbose

        Write-Host "Jobs Complete...$(Get-Date)"

        Receive-Job -Job $stagingConfigJob -Wait
        Receive-Job -Job $productionConfigJob -Wait
        
        Write-Host "Deleting Temporary Files...$(Get-Date)"

        Remove-Item $tmpStagingCscfg -Force -ErrorAction SilentlyContinue
        Remove-Item $tmpProductionCsCfg -Force -ErrorAction SilentlyContinue

    }
    else 
    {
		Write-Host "Swapping VIP...$(Get-Date)"

        Move-AzureDeployment -ServiceName $ServiceName -Verbose
    }
    
    if ($RemoveStagingDeploymentSlot)
    {
        Write-Host "Removing Staging Deployment for $ServiceName"
        Remove-AzureDeployment -ServiceName $ServiceName -Slot Staging -DeleteVHD -Force -Verbose   
    
    }

}else 
{
    Write-Error "Deployments not available in all slots.  Cannot swap." -Category InvalidOperation
}