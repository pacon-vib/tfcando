variable "location" {
  type = string
  description = "Azure location to deploy resources to."
  default = "australiaeast"
}

variable "databricks_token" {
  type = string
  description = "Access token for Databricks. Not for production use."
}
