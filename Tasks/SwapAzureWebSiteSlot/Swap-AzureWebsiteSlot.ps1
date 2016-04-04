param (
    [string] 
    $AppServiceName = $(throw "$AppServiceName is required."),
    
	[string]
	$Slot1,
    
    [string]
    $Slot2
    
   
 )

Write-Host "Get-AzureWebsite -Name $AppServiceName -Slot $Slot1"

$slot1Deployment = Get-AzureWebsite -Name $AppServiceName -Slot $Slot1 

Write-Host "Get-AzureWebsite -Name $AppServiceName -Slot $Slot2"

$slot2Deploymnet = Get-AzureWebsite -Name $AppServiceName -Slot $Slot2


if ($slot1Deployment -and $slot2Deploymnet)
{
    Switch-AzureWebsiteSlot -Name $AppServiceName -Slot1 $Slot1 -Slot2 $Slot2 -Force -Verbose
}
else 
{
    if (-not $slot1Deployment){
        Write-Error "Unable to find $(Slot1) Deployment Slot App Service $(AppServiceName)"
    }
     if (-not $slot2Deployment){
        Write-Error "Unable to find $(Slot2) Deployment Slot App Service $(AppServiceName)"
    }
    
}