#!/bin/bash

set -e

kaleidoPath="${1:-${HOME}/GitHub/kaleido-io/}"
githubUsername="${2:-hfuss}"

pushd ${kaleidoPath} > /dev/null

    # clone if the repos don't exist
    [[ -d "quorum-tools" ]] || git clone git@github.com:kaleido-io/quorum-tools.git
    [[ -d "quorum" ]] || git clone git@github.com:kaleido-io/quorum.git
    [[ -d "constellation" ]] || git clone git@github.com:kaleido-io/constellation.git
    [[ -d "istanbul-tools" ]] || git clone git@github.com:getamis/istanbul-tools.git

    pushd quorum-tools > /dev/null

        # make docker isn't idempotent if the images already exist, so this is a hack
        # to speed things up if the images exist
        set +e
        for image in quorum quorum-builder constellation constellation-base; do
            docker inspect jpmorganchase/${image} > /dev/null
            if [[ "$?" -eq "1" ]]; then
                set -e
                make docker
                break
            fi
        done
        docker inspect istanbul-tools > /dev/null
        if [[ "$?" -eq "1" ]]; then
            set -e
            make docker
        fi
        set -e

        # push images to ghcr
        for image in quorum quorum-builder constellation constellation-base; do
            docker tag jpmorganchase/${image} ghcr.io/${githubUsername}/${image}
            docker push ghcr.io/${githubUsername}/${image}
        done

        docker tag istanbul-tools ghcr.io/${githubUsername}/istanbul-tools
        docker push ghcr.io/${githubUsername}/istanbul-tools
    popd > /dev/null

popd > /dev/null

# config-generator just has the tools necessary to generate all the quorum and constellation keys
docker build quorum-config-generator/ -t ghcr.io/${githubUsername}/quorum-config-generator
docker push ghcr.io/${githubUsername}/quorum-config-generator