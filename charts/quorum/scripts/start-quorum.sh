#!/bin/bash

id="${HOSTNAME##*-}"
bootnode_enode=$(cat /qdata_all/bootnode_enode)

# wait for constellation to start w/ exponential backoff
i=1
until [[ -e "/constellation/tm.ipc" ]]; do
  echo "constellation has not created socket, waiting $i sec to start quorum"
  sleep $i
  i=$(($i**2 + 1))
done

exec start.sh --bootnode="${bootnode_enode}@${BOOTNODE_SVC}:30301" --raftInit  --networkid 2018
