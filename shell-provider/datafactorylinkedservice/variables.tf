variable "location" {
  type = string
  description = "Azure location to deploy resources to."
  default = "australia east"
}

variable "resource_group_name" {
  type = string
  description = "Name of an existing resource group into which to deploy resources."
}

variable "data_factory_name" {
  type = string
  description = "Name for the Data Factory to be deployed"
}

variable "data_lake_name" {
  type = string
  description = "Name of an existing ADLS storage account, to which the Data Factory should be linked."
}
