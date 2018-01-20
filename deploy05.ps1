#
# deploy.ps1
#

#Login-AzureRmAccount

$subscriptionId = '60b6165a-8669-47a2-860c-6ef475127364'

$parameters=@{
    workspaceRegion = "canadacentral"
    environmentName ="AzureCloud"
    keyVaultName = "GCKeystoreUser5"
    keyVaultResourceGroupName = "GCbluePrintUser5"
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
New-AzureRmResourceGroupDeployment -Name "D_$timestamp" -ResourceGroupName GCbluePrintUser5 `
-TemplateFile .\azuredeploy.json -TemplateParameterObject $parameters `
-Mode Incremental -DeploymentDebugLogLevel ResponseContent -Verbose 

