#!/bin/bash

set -e

# for macos assumes vm will use hyperkit: https://minikube.sigs.k8s.io/docs/drivers/hyperkit/

vm=false
if [[ "${OSTYPE}" == "darwin"* ]]; then
  vm=true
fi

minikube start --vm=${vm} --addons ingress --cpus 6 --memory 6g --cache-images
