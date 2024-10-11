#powershell script for shutdown and startup windows server in azure multiple vm
#steps - Automation Account, Create a Runbook, Create a Schedule, Link the Schedule to the Runbook

#Prerequisites
Install-Module -Name Az -AllowClobber -Scope CurrentUser
Connect-AzAccount

#Stop Multiple Azure VMs - file name as "Stop-MultipleAzureVMs.ps1"

param (
    # An array of hashtable elements where each hashtable contains 'ResourceGroupName' and 'VmName'
    [array]$VmList
)

# Login to Azure Account (if not already logged in)
if (-not (Get-AzContext)) {
    Connect-AzAccount
}

foreach ($vm in $VmList) {
    try {
        $resourceGroupName = $vm.ResourceGroupName
        $vmName = $vm.VmName
        
        Write-Output "Stopping VM: $vmName in Resource Group: $resourceGroupName"
        Stop-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -Force -ErrorAction Stop
        
        Write-Output "Successfully stopped VM: $vmName"
    } catch {
        Write-Output "Failed to stop VM: $vmName. Error: $_"
    }
}


# Start Multiple Azure VMs - file name as "Start-MultipleAzureVMs.ps1"

param (
    # An array of hashtable elements where each hashtable contains 'ResourceGroupName' and 'VmName'
    [array]$VmList
)

# Login to Azure Account (if not already logged in)
if (-not (Get-AzContext)) {
    Connect-AzAccount
}

foreach ($vm in $VmList) {
    try {
        $resourceGroupName = $vm.ResourceGroupName
        $vmName = $vm.VmName
        
        Write-Output "Starting VM: $vmName in Resource Group: $resourceGroupName"
        Start-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -ErrorAction Stop
        
        Write-Output "Successfully started VM: $vmName"
    } catch {
        Write-Output "Failed to start VM: $vmName. Error: $_"
    }
}



#Calling above file 

# Define the list of VMs
$vmList = @(
    @{ ResourceGroupName = "RG1"; VmName = "RG1-VM1" },
	@{ ResourceGroupName = "RG1"; VmName = "RG1-VM2" },
    @{ ResourceGroupName = "RG2"; VmName = "RG2-VM1" },
	@{ ResourceGroupName = "RG2"; VmName = "RG2-VM2" },
    # Add more VMs as needed
)

# Stop the VMs
.\Stop-MultipleAzureVMs.ps1 -VmList $vmList

# Start the VMs
.\Start-MultipleAzureVMs.ps1 -VmList $vmList
