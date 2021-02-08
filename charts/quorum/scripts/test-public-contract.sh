#!/bin/bash

set -e

echo "Attempting to mine public contract"
# we can't tell from the return code if the script succeeds, but it does print "true"
geth attach /qdata/ethereum/geth.ipc --exec "loadScript('/scripts/public-contract.js')" | grep true
echo "Transaction was successful"
