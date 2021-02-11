#!/bin/bash

set -e

set +e
helm get all quorum -n kaleido > /dev/null 2>&1
release=$?
set -e

# pre-install hooks dont work w/ `upgrade --install`
if [[ "$release" -eq "1" ]]; then
  helm install -n kaleido quorum charts/quorum --wait --timeout 240s
else
  helm upgrade --atomic --install -n kaleido quorum charts/quorum --wait --timeout 240s
fi

helm upgrade --atomic --install -n kaleido racecourse charts/racecourse --wait --timeout 120s

set +e
cat /etc/hosts | grep racecourse.local
hosts=$?
set -e

if [[ "$hosts" -eq "1" ]]; then
  echo "Appending racecourse.local to /etc/hosts"
  echo "$(minikube ip) racecourse.local" | sudo tee -a /etc/hosts
fi