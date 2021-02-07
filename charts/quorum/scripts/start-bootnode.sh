#!/bin/bash

if [[ ! -e "/qdata/nodekey" ]]; then
  cp -ir /qdata_all/qdata_boot/* /qdata/
fi

exec bootnode -nodekey /qdata/nodekey
