#!/bin/bash

if minikube status > /dev/null; then
  echo "cluster already exists, skipping"
  exit 0
fi

set -e

# for macos assumes vm will use hyperkit: https://minikube.sigs.k8s.io/docs/drivers/hyperkit/

vm=false
if [[ "${OSTYPE}" == "darwin"* ]]; then
  vm=true
fi

minikube start --vm=${vm} --addons ingress --cpus 8 --memory 8g --cache-images
