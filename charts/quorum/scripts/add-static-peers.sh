#!/bin/bash

set -e

# sleep to ensure DNS records get made for each node
sleep 20

for i in $(seq 2 $NUM_NODES)
do
  k=$((i-1))
  enode_url=$(python -c "import json; data = json.loads(open('/qdata/ethereum/static-nodes.json').read()); print data[$k]")
  echo "Adding peer $enode_url"
  geth attach /qdata/ethereum/geth.ipc --exec "raft.addPeer(\"$enode_url\")" | grep $i
done
