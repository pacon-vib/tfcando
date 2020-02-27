# Data Factory linked service demo for the shell provider (PowerShell)

* Run `terraform apply` to deploy an Azure Data Factory with a "linked service" connection to a data lake in a storage account.
* This module assumes that you already have a storage account for the Data Factory to link to. You can specify the name of this storage account in `terraform.tfvars`.
* To run this demo, you will need to have Powershell Core and the PowerShell Az module installed.
