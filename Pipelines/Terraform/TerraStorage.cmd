REM will create azure resource group for terraform workspace. terraform maintains its state here. 



az group create --location westus --name $(terraformstoragerg) 
                              
az storage account create --name $(terraformstorageaccount) --resource-group $(terraformstoragerg) --location westus --sku standard_LRS 
                              
# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $(terraformstoragerg)  --account-name $(terraformstorageaccount) --query '[0].value' -o tsv)
az storage container create --name $(terraformcontainer) --account-name $(terraformstorageaccount) --account-key $ACCOUNT_KEY
