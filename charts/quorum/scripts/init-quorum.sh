#!/bin/bash

set -e

id="${HOSTNAME##*-}"
echo "device id: $id"
echo "bootnode enode: $(cat /qdata_all/bootnode_enode)"
qd=/qdata_all/qdata_${id}
ls $qd
if [[ ! -d "/qdata/constellation" ]]; then
  echo
  cp -ri $qd/constellation /qdata/
else
  cp -i $qd/constellation/tm* /qdata/
fi

if [[ ! -d "/qdata/ethereum" ]]; then
  cp -ri $qd/ethereum /qdata/
else
  cp -i $qd/ethereum/genesis.json /qdata/ethereum/
  cp -i $qd/ethereum/nodekey /qdata/ethereum/
  cp -i $qd/ethereum/passwords.txt /qdata/ethereum/
  cp -i $qd/ethereum/permissioned-nodes.json /qdata/ethereum
  cp -i $qd/ethereum/static-nodes.json /qdata/ethereum
fi

mkdir -p /qdata/logs
touch /qdata/logs/dummy.txt

ls /qdata/constellation
ls /qdata/ethereum
ls /qdata/logs
