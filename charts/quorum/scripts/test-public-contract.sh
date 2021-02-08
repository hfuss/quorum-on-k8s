#!/bin/bash

set -e

echo "Attempting to mine public contract"
geth attach /qdata/ethereum/geth.ipc --exec "loadScript('/scripts/public-contract.js')" | grep true
echo "Transaction was successful"
