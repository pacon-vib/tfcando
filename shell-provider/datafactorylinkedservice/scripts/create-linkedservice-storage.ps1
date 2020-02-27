#!/usr/bin/env pwsh

#
# Create a linked service to an ADLS storage account from Data Factory
#

# Interpolate variable(s) into the config file for the linked service
$tmp_conf_file = New-TemporaryFile
$env:linked_service_config | Out-File $tmp_conf_file

# Create the linked service
$new_details = Set-AzDataFactoryV2LinkedService -DataFactoryName $env:data_factory_name -ResourceGroupName $env:resource_group_name -Name $env:linked_service_name -File $tmp_conf_file -Force

# Save state
$new_state = @{ id = $new_details.Id;
		name = $new_details.Name;
		resource_group_name = $new_details.ResourceGroupName;
		data_factory_name = $new_details.DataFactoryName
	      } | ConvertTo-Json
write-host "New state:"
write-host $new_state
$new_state_bytes = [System.Text.Encoding]::UTF8.GetBytes($new_state)
$fs = [System.IO.File]::OpenWrite("/dev/fd/3")
$fs.Write($new_state_bytes, 0, $new_state_bytes.length)
$fs.Flush()

# Clean up temporary config file
Remove-Item $tmp_conf_file
