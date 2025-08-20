#!/usr/bin/env bash

set -euo pipefail

cd "$(
    dirname "$(
        realpath "$0"
    )"
)"

(
    printf '%s\n' 'FROM ubuntu:latest'

    jq -c '.[]' <<< "$(cat .github/workflows/.gitlab-ci.yml | jq '.jobs.build.steps[].run | select(.)' | jq -s)" | while IFS= read -r item; do
        if [ "$item" = '":"' ]
        then
            printf '%s\n' 'COPY . .'
        else
            printf 'RUN '
            jq -c '["sh", "-c", .]' <<< "$item"
        fi
    done
) > Dockerfile

docker build --progress=plain -t ubuntu-in-runner .
