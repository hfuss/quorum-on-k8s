#!/bin/bash

set -e

set +e
helm get all quorum -n kaleido > /dev/null 2>&1
set -e

# pre-install hooks dont work w/ `upgrade --install`
if [[ "$?" -eq "1" ]]; then
  helm install -n kaleido quorum charts/quorum --wait
else
  helm upgrade --atomic --install -n kaleido quorum charts/quorum --wait
fi

helm upgrade --atomic --install -n kaleido racecourse charts/racecourse --wait

set +e
cat /etc/hosts | grep racecourse.local
set -e

if [[ "$?" -eq "1" ]]; then
  echo "Appending racecourse.local to /etc/hosts"
  echo "$(minikube ip) racecourse.local" | sudo tee -a /etc/hosts
fi