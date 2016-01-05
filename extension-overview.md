# Build and Release Management Tasks for VSO


## Tasks

### Swap Azure Deployment Task

Swaps the staging and production deployment slots on a cloud service.  Optionally will switch the configurations (.cscfg) and delete the staging slot when completed.    

### Remove Azure Deployment Slot Task

Removes a specific Cloud Service deployment slot optionally removing the backing VHD.  

### Update Azure Configuration Setting

Updates a value in the Cloud Service configuration (.cscfg) in a specified deployment slot. 

