#
# Resource group for everything to go into
#
resource "azurerm_resource_group" "demo" {
  name                = var.resource_group_name
  location            = var.location
}

#
# Data Factory
#
resource "azurerm_data_factory" "demo" {
  name                = var.data_factory_name
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name
  identity {
    type = "SystemAssigned"
  }

}

#
# "Linked service" for Data Factory to access data lake
#
resource "shell_script" "demo_linkedservice" {
  lifecycle_commands {
    create = "pwsh -File scripts/create-linkedservice-storage.ps1"
    read   = "pwsh -File scripts/read-linkedservice-storage.ps1"
    # update is omitted; there is no corresponding cmdlet; therefore we destroy and re-create
    delete = "pwsh -File scripts/delete-linkedservice-storage.ps1"
  }

  working_directory = path.module

  environment = {
    data_factory_name = azurerm_data_factory.demo.name
    resource_group_name = azurerm_resource_group.demo.name
    linked_service_name = "AzureDataLakeGen2LinkedService2"
    linked_service_config = <<-EOF
                               {
                                   "name": "AzureDataLakeStorageGen2LinkedService",
                                   "properties": {
                                       "type": "AzureBlobFS",
                                       "typeProperties": {
                                           "url": "https://${var.data_lake_name}.dfs.core.windows.net"
                                       }       
                                   }
                               }
                               EOF
  }
}
