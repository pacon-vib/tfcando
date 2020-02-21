# Databricks demo for the shell provider (Bash)

* Run `terraform apply` to deploy a Databricks workspace with a cluster. The latter is not supported by the azurerm provider, but you can curl the API from Bash via the shell provider.
* Authenticating with a Databricks workspace requires a trip to the Databricks web portal, so you'll actually have to run `apply` twice. The first run will create the workspace and then die trying to create the cluster. At this point you'll need to visit the web portal, generate a token, and then run `terraform apply -var=databricks_token=YOURTOKENHERE`. If you were to put this into production then you'd handle that secret differently (e.g. via Key Vault).
