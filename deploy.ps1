
#
# deploy.ps1
#

#Login-AzureRmAccount

#$subscriptionId = '60b6165a-8669-47a2-860c-6ef475127364'
#Set-AzureRmContext -SubscriptionId $subscriptionId
$timestamp = Get-Date -Format "yyyy-MM-dd_hh-mm-ss"
$resourceGroupName = 'GCBlueprintUser4'
$keyvaultName="GCKeystoreUser4"
$parametersFile='.\azuredeploy.parameters.json'

#
# Provision Basic Services / OMS Workspaces
#
New-AzureRmResourceGroupDeployment -Name "D_$timestamp" -ResourceGroupName $resourceGroupName `
-TemplateFile .\azuredeploy01.json -TemplateParameterFile $parametersFile `
-Mode Incremental -Verbose 
#
# Provision Domain Controllers
#
New-AzureRmResourceGroupDeployment -Name "D_$timestamp" -ResourceGroupName $resourceGroupName `
-TemplateFile .\azuredeploy02.json -TemplateParameterFile $parametersFile `
-Mode Incremental -Verbose 

Restart-AzureRmVM -ResourceGroupName $resourceGroupName -Name "AZ-PDC-VMprod" -Verbose
Restart-AzureRmVM -ResourceGroupName $resourceGroupName -Name "AZ-BDC-VMprod" -Verbose

Start-Sleep -Seconds 120

#
# Provision Domain Controllers Backups
#
New-AzureRmResourceGroupDeployment -Name "D_$timestamp" -ResourceGroupName $resourceGroupName `
-TemplateFile .\azuredeploy03.json -TemplateParameterFile $parametersFile `
-Mode Incremental -Verbose 

#
# App GW, other VMs
#
New-AzureRmResourceGroupDeployment -Name "D_$timestamp" -ResourceGroupName $resourceGroupName `
-TemplateFile .\azuredeploy04.json -TemplateParameterFile $parametersFile `
-Mode Incremental -Verbose 

#
# Everything else
#
New-AzureRmResourceGroupDeployment -Name "D_$timestamp" -ResourceGroupName $resourceGroupName `
-TemplateFile .\azuredeploy05.json -TemplateParameterFile .\azuredeploy.parameters.json `
-Mode Incremental -Verbose 

#
# Encryption
#



#$keyVaultResourceId = '/subscriptions/3a4af7b3-b7ac-463d-9940-1d80445961a8/resourceGroups/GCbluePrintUser3/providers/Microsoft.KeyVault/vaults/GCKeystoreUser3'

$keyvault=Get-AzureRmKeyVault -VaultName $keyvaultName
$aadClientID= (Get-AzureKeyVaultSecret -VaultName $keyvaultName -Name "aadClientID").SecretValueText
$aadClientSecret=(Get-AzureKeyVaultSecret -VaultName $keyvaultName -Name "aadClientSecret").SecretValueText
$keyVaultResourceId=$keyvault.ResourceId
$diskEncryptionKeyVaultUrl=$keyvault.VaultUri

Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $resourceGroupName -VMName 'AZ-PDC-VMprod' -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $keyVaultResourceId -VolumeType All -Verbose -Force
Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $resourceGroupName -VMName 'AZ-BDC-VMprod' -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $keyVaultResourceId -VolumeType All -Verbose -Force
Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $resourceGroupName -VMName 'AZ-MGT-VMprod' -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $keyVaultResourceId -VolumeType All -Verbose -Force

Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $resourceGroupName -VMName 'AZ-WEB-VMprod0' -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $keyVaultResourceId -VolumeType All -Verbose -Force
Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $resourceGroupName -VMName 'AZ-WEB-VMprod1' -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $keyVaultResourceId -VolumeType All -Verbose -Force

Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $resourceGroupName -VMName 'cluster-fswprod' -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $keyVaultResourceId -VolumeType All -Verbose -Force

Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $resourceGroupName -VMName 'sqlserver0prod' -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $keyVaultResourceId -VolumeType All -Verbose -Force
Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $resourceGroupName -VMName 'sqlserver1prod' -AadClientID $aadClientID -AadClientSecret $aadClientSecret -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $keyVaultResourceId -VolumeType All -Verbose -Force


