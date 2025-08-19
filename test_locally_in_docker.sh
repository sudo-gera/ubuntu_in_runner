#!/usr/bin/env bash

set -euo pipefail

cd "$(
    dirname "$(
        realpath "$0"
    )"
)"

(
    printf '%s\n' 'FROM ubuntu:latest'

    jq -c '.build_job.script[]' <<< "$(cat .gitlab-ci.yml)" | while IFS= read -r item; do
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
