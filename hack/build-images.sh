#!/bin/bash

set -e

kaleidoPath="${1:-${HOME}/GitHub/kaleido-io/}"
githubUsername="${2:-hfuss}"

pushd ${kaleidoPath} > /dev/null

    # clone if the repos don't exist
    [[ -d "quorum-tools" ]] || git clone git@github.com:kaleido-io/quorum-tools.git
    # have to use my fork for enode to have DNS support
    [[ -d "quorum" ]] || git clone git@github.com:hfuss/quorum.git
    [[ -d "constellation" ]] || git clone git@github.com:kaleido-io/constellation.git
    [[ -d "istanbul-tools" ]] || git clone git@github.com:getamis/istanbul-tools.git

    pushd quorum-tools > /dev/null

        # make docker isn't idempotent if the images already exist, so this is a hack
        # to speed things up if the images exist
        # to force images to build use `docker rmi`
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
        for image in quorum-builder constellation constellation-base; do
            docker tag jpmorganchase/${image} ghcr.io/${githubUsername}/${image}
            docker push ghcr.io/${githubUsername}/${image}
        done

        docker tag jpmorganchase/quorum ghcr.io/${githubUsername}/quorum-base
        docker push ghcr.io/${githubUsername}/quorum-base

        docker tag istanbul-tools ghcr.io/${githubUsername}/istanbul-tools
        docker push ghcr.io/${githubUsername}/istanbul-tools
    popd > /dev/null

popd > /dev/null

# quorum is just the  jqpmorganchase/quorum + dumb-init
# config-generator just has the tools necessary to generate all the quorum and constellation keys
for image in quorum quorum-config-generator; do
  docker build ${image}/ -t ghcr.io/${githubUsername}/${image}
  docker push ghcr.io/${githubUsername}/${image}
done
