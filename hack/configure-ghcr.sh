#!/bin/bash

set -e

gh_access_token="${1}"
gh_username="${2:-$(whoami)}"

docker login ghcr.io --username ${gh_username} --password ${gh_access_token}
kubectl create secret docker-registry -n kaleido \
  --docker-server=https://ghcr.io \
  --docker-username=${gh_username} \
  --docker-password=${gh_access_token} github-creds
