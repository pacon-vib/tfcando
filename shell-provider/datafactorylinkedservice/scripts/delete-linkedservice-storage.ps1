#!/usr/bin/env pwsh

#
# Delete the linked service for a Data Factory and an ADLS storage
#

# Get existing state
$old_state = [System.IO.File]::OpenText("/dev/stdin").ReadToEnd() | ConvertFrom-Json
write-host "Old state..."
write-host $old_state

Remove-AzDataFactoryV2LinkedService -DataFactoryName $old_state.data_factory_name -ResourceGroupName $old_state.resource_group_name -Name $old_state.name -Force
