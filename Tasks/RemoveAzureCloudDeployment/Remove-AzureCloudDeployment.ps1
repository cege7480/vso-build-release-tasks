param (
    [string] 
    $ServiceName = $(throw "-$ServiceName is required."),
    
    [string]    
    $Slot = "Staging",
    
    [string]
    $DeleteVHD = $false    
 )

if ($DeleteVHD){
    Remove-AzureDeployment -ServiceName $ServiceName -Slot $Slot -Force -DeleteVHD
}
else
{
    Remove-AzureDeployment -ServiceName $ServiceName -Slot $Slot -Force     
} 