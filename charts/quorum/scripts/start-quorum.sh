#!/bin/bash

id="${HOSTNAME##*-}"
bootnode_enode=$(cat /qdata_all/bootnode_enode)

# wait for constellation to start w/ fibonocci backoff
i=1
j=1
until [[ -e "/qdata/constellation/tm.ipc" ]]; do
  echo "constellation has not created socket, waiting $j sec to start quorum"
  sleep $j
  k=$j
  j=$(($k + $i))
  i=$k
done

node /usr/local/src/index.js --bootnode="enode://${bootnode_enode}@${BOOTNODE_SVC}.${NAMESPACE}.svc.cluster.local:30301" --raftInit  --networkid 2018

CHAIN_RECONFIG_MARKER_FILE="/qdata/ethereum/.chain_reconfigure"
GETH_NODES_DB_DIR="/qdata/ethereum/geth/nodes"

if [ ! -f /qdata/args.txt ]; then
  echo "!!! FATAL !!! - missing /qdata/args.txt, unable to start geth"
  exit 1
fi

# Purge the 'nodes' directory so that peering with all nodes is re-established on
# startup. Without this, pause/resume flow changes IP address of pods/geth nodes
# which causes loss of peering, mainly because bootnode does not recognize 'findnode'
# requests from geth nodes in the chain
if [ -d $GETH_NODES_DB_DIR ]; then
  echo "Found nodes db in geth node, wiping it clean to force bonding with all peers in the chain"
  rm -rf $GETH_NODES_DB_DIR
fi

#
# ALL SET!
#
if [ ! -d /qdata/ethereum/chaindata ] || [ -f $CHAIN_RECONFIG_MARKER_FILE ]; then
  echo "[*] Setting up chain config & genesis block"
  geth --datadir /qdata/ethereum init /qdata/ethereum/genesis.json
  # remove the chain reconfig marker file
  rm -f $CHAIN_RECONFIG_MARKER_FILE
fi

GETH_ARGS=`cat /qdata/args.txt`
echo "[*] Starting node with args $GETH_ARGS"
export PRIVATE_CONFIG=/qdata/constellation/tm.conf
exec dumb-init --rewrite 15:2 geth $GETH_ARGS --metrics
