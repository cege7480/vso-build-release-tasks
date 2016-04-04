param (
    [string]
    $ConnectedServiceName = $(throw "-$ServiceName is required."),
    
        [string] 
    $AppServiceName = "bookshop-ct",
    
	[string]
	$SourceSlot = "production",
    
    [string]
    $DestinationSlot = "maint",
    
    [string]
    $DestinationAppServiceRouteName = "MaintenancePageRoute",
    
    [int]
    $ReroutePercentage = 100,
    
    [int]
    $ChangeIntervalInMinutes = 3,
    
    [int]
    $ChangeStep = 5,
    
    [int]
    $MinReroutePercentage = 5,
    
    [int]
    $MaxReroutePercentage = 100,

    [bool]
    $RemoveRoute ,

    [bool]
    $RemoveAllRoutes
    
    
)
Write-Host "Get-AzureWebsite -Name $AppServiceName -Slot $SourceSlot"

$sourceSlotDeployment = Get-AzureWebsite -Name $AppServiceName -Slot $SourceSlot 


if ($RemoveAllRoutes){
    Write-Host "Clearning all existing routes..."
    $sourceSlotDeployment.RoutingRules = $null
    Set-AzureWebsite -Name $AppServiceName -RoutingRules $null
}
else 
{
    
    Write-Host "Searching for existing route $DestinationAppServiceRouteName on $AppServiceName..."

       

    $previousRouteRules = $sourceSlotDeployment.RoutingRules | Where { $_.Name -eq $DestinationAppServiceRouteName }
    $existingRouteRules = $sourceSlotDeployment.RoutingRules

    if (($previousRouteRules) -and $RemoveRoute)
    {              
        Write-Host "Existing Route found.  Removing..."
        
        #need this to copy existing routes...
        


        $existingRouteRules.Remove($previousRouteRules)

        
        Set-AzureWebsite -Name $AppServiceName -RoutingRules $existingRouteRules
    }
    else 
    {
        
        Write-Host "Get-AzureWebsite -Name $AppServiceName -Slot $DestinationSlot"

        $sourceSlotDeployment = Get-AzureWebsite -Name $AppServiceName -Slot $DestinationSlot

        # Write-Host "Get App Service Plan, determine if enough slots exist in case Splashpage slot doesnt exist"

        Write-host "Eventually download some content and publish it there..."

        Write-Host "Creating Traffic Route $DestinationAppServiceRouteName - ActionHost: $DestinationSlot, ReroutePercentage: $ReroutePercentage, ChangeIntervalInMinutes: $ChangeIntervalInMinutes, ChangeStep: $ChangeStep,  "

        $rule1 = New-Object Microsoft.WindowsAzure.Commands.Utilities.Websites.Services.WebEntities.RampUpRule
        $rule1.ActionHostName = $DestinationSlot
        $rule1.Name = $DestinationAppServiceRouteName
        $rule1.ReroutePercentage = $ReroutePercentage        
        $rule1.ChangeIntervalInMinutes = $ChangeIntervalInMinutes
        $rule1.ChangeStep = $ChangeStep
        $rule1.MinReroutePercentage = $MinReroutePercentage
        $rule1.MaxReroutePercentage = $MaxReroutePercentage

        Write-Host "Call Set-AzureWebsite with new routing rules..."

        if ($existingRouteRules)
        {
            Write-Host "Adding to Existing Rules..."
            $existingRouteRules = $sourceSlotDeployment.RoutingRules
            $existingRouteRules.Add($rule1)
            $existingRouteRules
            Set-AzureWebsite $AppServiceName -Slot $SourceSlot -RoutingRules $existingRouteRules
        }
        else 
        {
            Write-Host "Setting Routing Rules..."
            Set-AzureWebsite $AppServiceName -Slot $SourceSlot -RoutingRules $rule1
        }

    }
   
 }


