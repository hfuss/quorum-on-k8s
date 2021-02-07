#
# This is used at Container start up to run the constellation and geth nodes
#

set -u
set -e

node /usr/local/src/index.js --constellation

cat /qdata/constellation/tm.conf

echo "[*] Starting Constellation node"
exec constellation-node /qdata/constellation/tm.conf -v3
