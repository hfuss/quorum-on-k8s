#!/bin/bash

bootnode -genkey /qdata_all/nodekey
constellation-node --generatekeys=tm < /dev/null > /dev/null
mv tm.* /qdata_all/
