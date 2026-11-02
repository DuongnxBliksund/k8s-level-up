#!/usr/bin/env bash
# Removes the level 0 container and image, then cleans the training ground.
# ./cleanup.sh          removes Docker resources, keeps training progress and answers
# ./cleanup.sh --reset  also deletes training progress, answers and data
set -uo pipefail
cd "$(dirname "$0")"

if docker container inspect level-0 >/dev/null 2>&1; then
    docker rm -f level-0 >/dev/null && echo "removed container level-0"
fi

if docker image inspect k8s-game/level-0 >/dev/null 2>&1; then
    docker rmi k8s-game/level-0 >/dev/null && echo "removed image k8s-game/level-0"
fi

./training/cleanup.sh "$@"
