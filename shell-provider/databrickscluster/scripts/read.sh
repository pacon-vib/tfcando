#!/bin/bash

set -e

echo hello read
echo hello read >&2

# Get existing state, if any
echo Old state...
OLD_STATE="$(cat)"
echo $OLD_STATE

CLUSTER_ID="$(echo $OLD_STATE | jq '.cluster_id' -r)"
trap 'ERR=$?; echo Read Databricks cluster API call failed; exit $ERR' ERR
CLUSTER_INFO="$(curl -H "Authorization: Bearer ${databricks_token}" "${databricks_api_root}/api/2.0/clusters/get?cluster_id=${CLUSTER_ID}")"
trap - ERR
echo Cluster info...
echo $CLUSTER_INFO | jq '.'
NEW_STATE="$(jq -n --arg cluster_id "$(echo $CLUSTER_INFO | jq '.cluster_id' -r)" --arg cluster_state "$(echo $CLUSTER_INFO | jq '.state' -r)"  '{cluster_id: $cluster_id, state: $cluster_state}')"

echo "New state..."
echo "$NEW_STATE" | jq '.'
echo "$NEW_STATE" >&3
