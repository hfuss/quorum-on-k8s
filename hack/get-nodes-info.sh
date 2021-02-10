#!/bin/bash

set -e

nodes=$(kubectl get po -n kaleido -l app.kubernetes.io/component=quorum -o jsonpath='{ ..metadata.name }')
nodes_array=($nodes)

for node in "${nodes_array[@]}"; do
  nodeIp=$(kubectl get -n kaleido pod ${node} -o jsonpath='{ .status.podIP }')
  account=$(kubectl exec --stdin --tty ${node} -n kaleido -c quorum -- geth account list --datadir /qdata/ethereum \
    | grep 'Account' \
    | awk '{print $3}')
  accountId=$(echo $account | tr -d '{}')

  echo "$node"
  echo "  IP: ${nodeIp}"
  echo "  AccountID: ${accountId}"
  echo
done


