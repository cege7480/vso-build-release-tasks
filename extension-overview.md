# Build and Release Management Tasks for VSO


## Tasks

### Swap Azure Deployment Task

Swaps the staging and production deployment slots on a cloud service.  Optionally will switch the configurations (.cscfg) and delete the staging slot when completed.    

### Remove Azure Deployment Slot Task

Removes a specific Cloud Service deployment slot optionally removing the backing VHD.  

### Update Azure Configuration Setting

Updates a value in the Cloud Service configuration (.cscfg) in a specified deployment slot. 

## Links

Some of the links below I used to either learn how to construct the build extension or some of the code within the tasks. Thanks to these people, saved me a lot of debuging time.   

* https://github.com/colindembovsky/cols-agent-tasks
* http://colinsalmcorner.com/post/developing-a-custom-build-vnext-task-part-1
* http://www.colinsalmcorner.com/post/developing-a-custom-build-vnext-task-part-2
* https://github.com/codingoutloud/pageofphotos/blob/master/deploy/azure-vip-swap-plus.ps1