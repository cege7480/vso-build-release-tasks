# Build and Release Management Tasks for VSO


## Tasks

### Swap Azure Cloud Service Deployment Task

Swaps the staging and production deployment slots on a cloud service.  Optionally will switch the configurations (.cscfg) and delete the staging slot when completed.

Possible Use Cases:

- Deploying an application for smoke testing on the staging slot of a cloud service, upon completition, swap the VIP  
- Adding new values to the .cscfg in staging that you want to carry over cleanly into production
- Save compute costs by not running an uneeded slot deployment   

### Remove Azure Cloud Service Deployment Slot Task

Removes a specific Cloud Service deployment slot optionally removing the backing VHD.  

### Update Azure Cloud Service Configuration Setting

Updates a value in the Cloud Service configuration (.cscfg) in a specified deployment slot. 

### Questions?

Email me at chris.taylor at polarissolutions.com