#!/bin/bash

set -e

# Get existing state, if any
echo hello
echo hello >&2
OLD_STATE="$(cat)"
echo $OLD_STATE

echo Create new cluster...
NEW_CLUSTER_SPEC="$(jq -n --arg cluster_name $cluster_name --arg num_workers $num_workers --arg spark_version $spark_version --arg node_type_id $node_type_id '{cluster_name: $cluster_name, num_workers: $num_workers, spark_version: $spark_version, node_type_id: $node_type_id}')"
echo New cluster spec:
echo $NEW_CLUSTER_SPEC

echo Running curl...
trap 'ERR=$?; echo Create Databricks cluster API call failed; exit $ERR' ERR
NEW_CLUSTER_INFO="$(curl -s -H "Authorization: Bearer ${databricks_token}" "${databricks_api_root}/api/2.0/clusters/create" -d "${NEW_CLUSTER_SPEC}")"
trap - ERR
echo $NEW_CLUSTER_INFO | jq '.'
echo "Preparing state record..."
NEW_STATE="$(jq -n --arg cluster_id "$(echo $NEW_CLUSTER_INFO | jq '.cluster_id' -r)" '{cluster_id: $cluster_id}')"

echo "New state..."
echo "$NEW_STATE" | jq '.'
echo "$NEW_STATE" >&3
