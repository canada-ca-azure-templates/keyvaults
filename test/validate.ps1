Param(
    [Parameter(Mandatory = $false)][string]$templateLibraryName = "keyvaults",
    [string]$templateName = "azuredeploy.json",
    [string]$Location = "canadacentral",
    [string]$subscription = "2de839a0-37f9-4163-a32a-e1bdb8d6eb7e"
)

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************

# Make sure we update code to git
git add . ; git commit -m "Update validation" ; git push origin dev

Select-AzureRmSubscription -Subscription $subscription

# Cleanup validation resource content in case it did not properly completed and left over components are still lingeringcd
Write-Host "Cleanup validation resource content...";
New-AzureRmResourceGroupDeployment -ResourceGroupName PwS2-validate-keyvaults-RG -Mode Complete -TemplateFile (Resolve-Path "$PSScriptRoot\parameters\cleanup.json") -Force -Verbose

# Start the deployment
Write-Host "Starting validation deployment...";

New-AzureRmDeployment -Location $Location -Name "Validate-keyvaults-template" -TemplateUri "https://raw.githubusercontent.com/canada-ca/accelerators_accelerateurs-azure/master/Templates/arm/masterdeploy/20190319.1/masterdeploysub.json" -TemplateParameterFile (Resolve-Path -Path "$PSScriptRoot\parameters\masterdeploysub.parameters.json") -Verbose;

$provisionningState = (Get-AzureRmDeployment -Name "Validate-keyvaults-template").ProvisioningState

if ($provisionningState -eq "Failed") {
    Write-Host "One of the jobs was not successfully created... exiting..."
    exit
}

# Cleanup validation resource content
Write-Host "Cleanup validation resource content...";
New-AzureRmResourceGroupDeployment -ResourceGroupName PwS2-validate-keyvaults-RG -Mode Complete -TemplateFile (Resolve-Path "$PSScriptRoot\parameters\cleanup.json") -Force -Verbose