#!/bin/bash

set -e

# Get existing state
echo hello-update
OLD_STATE="$(cat)"
echo $OLD_STATE

EXISTING_CLUSTER_ID="$(echo $OLD_STATE | jq '.cluster_id' -r)"
echo Existing cluster ID is $EXISTING_CLUSTER_ID...

echo Edit cluster...
NEW_CLUSTER_SPEC="$(jq -n --arg cluster_name $cluster_name --arg num_workers $num_workers --arg spark_version $spark_version --arg node_type_id $node_type_id --arg cluster_id $EXISTING_CLUSTER_ID '{cluster_id: $cluster_id, cluster_name: $cluster_name, num_workers: $num_workers, spark_version: $spark_version, node_type_id: $node_type_id}')"
echo New cluster spec:
echo $NEW_CLUSTER_SPEC
echo Running curl...
trap 'ERR=$?; echo Update Databricks cluster API call failed; exit $ERR' ERR
curl -s -H "Authorization: Bearer ${databricks_token}" "${databricks_api_root}/api/2.0/clusters/edit" -d "${NEW_CLUSTER_SPEC}"
trap - ERR
