resource "azurerm_resource_group" "demo" {
  name = "tfcando"
  location = var.location
}

resource "azurerm_databricks_workspace" "demo" {
  name                = "tfcando"
  resource_group_name = azurerm_resource_group.demo.name
  location            = var.location
  sku                 = "standard"
}

resource "shell_script" "cluster" {
  lifecycle_commands {
    create = "bash ${path.module}/scripts/create.sh"
    read   = "bash ${path.module}/scripts/read.sh"
    update = "bash ${path.module}/scripts/update.sh"
    delete = "bash ${path.module}/scripts/delete.sh"
  }

  environment = {
    cluster_name = "democluster"
    databricks_token = var.databricks_token
    databricks_api_root = "https://${var.location}.azuredatabricks.net"
    num_workers = 1
    spark_version = "6.2.x-scala2.11"
    node_type_id = "Standard_D3_v2"
  }

  depends_on = [
    azurerm_databricks_workspace.demo
  ]

  working_directory = "."
}
