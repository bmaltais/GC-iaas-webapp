#
# deploy.ps1
#

#Login-AzureRmAccount

$subscriptionId = '60b6165a-8669-47a2-860c-6ef475127364'

$parameters=@{
    workspaceRegion = "canadacentral"
    environmentName ="AzureCloud"
    keyVaultName = "GCKeystoreUser2"
    keyVaultResourceGroupName = "GCbluePrintUser2"
    domainName = "GCblueprint.local"
    configureSQLAO = "yes"
    environmentPrefix = "prod"
    numberOfWebInstances = 2
    useExistingKek = "kek"
   # encryptionEnabled = true
    adVMSize = "Standard_D2_v2"
    sqlVMSize = "Standard_D2_v2"
    webVMSize = "Standard_D2_v2"
    mgtVMSize = "Standard_D2_v2"
    witnessVMSize = "Standard_D2_v2"
    sqlStorageAccountType = "Standard_GRS"
    dcStorageAccountType = "Standard_GRS"
    webStorageAccountType = "Standard_GRS"
    mgtStorageAccountType = "Standard_GRS"
    templatesBaseUrl = "https://raw.githubusercontent.com/mosharafMS/GC-iaas-webapp/court/nestedtemplates"
    dscBaseUrl = "https://raw.githubusercontent.com/mosharafMS/GC-iaas-webapp/court/DSC"
    scriptsBaseUrl = "https://raw.githubusercontent.com/mosharafMS/GC-iaas-webapp/court/custom-scripts"
    sqlServerVersion = "SQL2016-WS2012R2"
    gatewaySkuName = "WAF_Medium"
}

#Get-AzureRmComputeResourceSku | where {$_.Locations.Contains("eastus")}

$timestamp = Get-Date -Format "yyyy-MM-dd_hh-mm-ss"
#
#
#
New-AzureRmResourceGroupDeployment -Name "D_$timestamp" -ResourceGroupName GCbluePrintUser2 `
-TemplateFile .\azuredeploy01.json -TemplateParameterObject $parameters `
-Mode Incremental -DeploymentDebugLogLevel ResponseContent -Verbose 

Write-Host "Sleeping for 20 seconds..." -ForegroundColor Yellow					
Start-Sleep 20 #sleep for 20 seconds
#
# Provision AD VMs
#
New-AzureRmResourceGroupDeployment -Name "D_$timestamp" -ResourceGroupName GCbluePrintUser2 `
-TemplateFile .\azuredeploy02.json -TemplateParameterObject $parameters `
-Mode Incremental -DeploymentDebugLogLevel ResponseContent -Verbose 

#
# Provision the rest
#
New-AzureRmResourceGroupDeployment -Name "D_$timestamp" -ResourceGroupName GCbluePrintUser2 `
-TemplateFile .\azuredeploy03.json -TemplateParameterObject $parameters `
-Mode Incremental -DeploymentDebugLogLevel ResponseContent -Verbose 
