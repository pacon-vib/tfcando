#!/bin/bash

set -e

# Get existing state
OLD_STATE="$(cat)"
echo Old state...
echo $OLD_STATE

EXISTING_CLUSTER_ID="$(echo $OLD_STATE | jq '.cluster_id' -r)"
echo Existing cluster ID is $EXISTING_CLUSTER_ID...

# Permanently delete cluster
echo Deleting cluster...
trap 'ERR=$?; echo Delete Databricks cluster API call failed; exit $ERR' ERR
curl -s -H "Authorization: Bearer ${databricks_token}" -X POST "${databricks_api_root}/api/2.0/clusters/permanent-delete" -d '{"cluster_id": "'"$EXISTING_CLUSTER_ID"'"}'
trap - ERR
