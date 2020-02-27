#!/usr/bin/env pwsh

#
# Read the details of the linked service for a Data Factory and an ADLS storage
#

# Get existing state
$old_state = [System.IO.File]::OpenText("/dev/stdin").ReadToEnd() | ConvertFrom-Json
write-host "Old state..."
write-host $old_state

$new_details = Get-AzDataFactoryV2LinkedService -DataFactoryName $old_state.data_factory_name -ResourceGroupName $old_state.resource_group_name -Name $old_state.name

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
