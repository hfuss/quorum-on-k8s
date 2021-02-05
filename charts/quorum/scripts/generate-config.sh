#!/bin/bash

qd_all=/qdata_all
qd_boot=${qd_all}/qdata_boot

#### Create directory for bootnode's configuration ##################
echo '[0] Configuring for bootnode'

mkdir ${qd_boot}
bootnode -genkey ${qd_boot}/nodekey
bootnode_enode=`bootnode -nodekey ${qd_boot}/nodekey -writeaddress | tr -d '[:space:]'`

echo "bootnode id: $bootnode_enode"

echo '[1] Creating Enodes and static-nodes.json.'

echo "[" > static-nodes.json

for i in $(seq 1 ${NUM_NODES}); do
  k=$((i-1))
  qd=${qd_all}/qdata_$k

  mkdir -p $qd/{logs,constellation}
  mkdir -p $qd/ethereum/geth
  touch $qd/logs/dummy.txt

  bootnode -genkey $qd/ethereum/nodekey
  enode=`bootnode -nodekey $qd/ethereum/nodekey -writeaddress | tr -d '[:space:]'`
  echo "  Node $k id: $enode"

  sep=`[[ $i < $NUM_NODES ]] && echo ","`
  echo '  "enode://'$enode'@'${HOST_PREFIX}-${k}':30303?discport=0&raftport=50400"'$sep >> static-nodes.json

done

echo "]" >> static-nodes.json

#### Create accounts, keys and genesis.json file #######################

echo '[2] Creating Ether accounts and genesis.json.'

# generate the allocated accounts section to be used in both Raft and IBFT
for i in $(seq 1 $NUM_NODES)
do
  k=$((i-1))
  qd=${qd_all}/qdata_$k

  # Generate an Ether account for the node
  touch $qd/ethereum/passwords.txt
  create_account="geth --datadir=$qd/ethereum --password $qd/ethereum/passwords.txt account new"
  account1=`$create_account | cut -c 11-50`
  echo "  Accounts for node $k: $account1"

  # Add the account to the genesis block so it has some Ether at start-up
  sep=`[[ $i < $NUM_NODES ]] && echo ","`
  cat >> alloc.json <<EOF
  "${account1}": { "balance": "1000000000000000000000000000" }${sep}
EOF
done

cat > genesis.json <<EOF
{
  "alloc": {
EOF

cat alloc.json >> genesis.json

  cat >> genesis.json <<EOF
  },
  "coinbase": "0x0000000000000000000000000000000000000000",
  "config": {
    "homesteadBlock": 0,
    "byzantiumBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "isQuorum":true,
    "chainId": 3543006677
  },
  "difficulty": "0x0",
  "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
  "gasLimit": "0x2FEFD800",
  "nonce": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp": "0x00"
}
EOF

#### Complete each node's configuration ################################

echo '[3] Creating Constellation keys'

#### Make node list for tm.conf ########################################

nodelist=
for i in $(seq 1 $NUM_NODES)
do
    k=$((i-1))
    sep=`[[ $i < $NUM_NODES ]] && echo ","`
    nodelist=${nodelist}${sep}'"http://'${HOST_PREFIX}-${k}':9000/"'
done

cat <<EOF > tm.conf.template
url = "http://_NODEIP_:9000/"
port = 9000
socket = "/qdata/constellation/tm.ipc"
othernodes = [_NODELIST_]
publickeys = ["/qdata/constellation/tm.pub"]
privatekeys = ["/qdata/constellation/tm.key"]
storage = "dir:/qdata/constellation/data"
EOF

for i in $(seq 1 $NUM_NODES)
do
    k=$((i-1))
    qd=${qd_all}/qdata_$k

    cat tm.conf.template \
        | sed s/_NODEIP_/${HOST_PREFIX}-${k}/g  \
        | sed s%_NODELIST_%$nodelist%g \
        > $qd/constellation/tm.conf

    cp genesis.json $qd/ethereum/genesis.json
    cp static-nodes.json $qd/ethereum/static-nodes.json
    cp static-nodes.json $qd/ethereum/permissioned-nodes.json

    # Generate Quorum-related keys (used by Constellation)

    /usr/local/bin/constellation-node --generatekeys=tm < /dev/null > /dev/null
    mv tm.{key,pub} $qd/constellation/

    echo '  Node '$i' public key: '`cat $qd/constellation/tm.pub`

done
rm -rf genesis.json static-nodes.json alloc.json tm.conf.template
