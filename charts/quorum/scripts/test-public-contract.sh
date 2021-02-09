#!/bin/bash

set -e

# wait for quorum to start w/ fibonocci backoff
i=1
j=1
until [[ -e "/qdata/ethereum/geth.ipc" ]]; do
  echo "geth has not created socket, waiting $j sec before re-attempting to run test"
  sleep $j
  k=$j
  j=$(($k + $i))
  i=$k
done

echo "Attempting to mine public contract"
# we can't tell from the return code if the script succeeds, but it does print "true"
geth attach /qdata/ethereum/geth.ipc --exec "loadScript('/scripts/public-contract.js')" | grep true
echo "Transaction was successful"
