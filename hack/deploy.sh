#!/bin/bash

helm get all quorum -n kaleido > /dev/null

# pre-install hooks dont work w/ `upgrade --install`
if [[ "$?" -eq "1" ]]; then
  helm install -n kaleido quorum charts/quorum --wait
else
  helm upgrade --install -n kaleido quorum charts/quorum --wait
fi

