#!/usr/bin/env bash

set -euo pipefail

cd "$(
    dirname "$(
        realpath "$0"
    )"
)"

docker build --progress=plain -t ubuntu-in-runner .
