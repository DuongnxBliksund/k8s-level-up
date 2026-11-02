#!/usr/bin/env bash
# Removes the training containers and image.
# ./cleanup.sh          removes Docker resources, keeps your progress and answers
# ./cleanup.sh --reset  also deletes progress.txt, answers/*.txt and data/visits.txt
set -uo pipefail
cd "$(dirname "$0")"

for c in move1-a move1-b move3 move4; do
    if docker container inspect "$c" >/dev/null 2>&1; then
        docker rm -f "$c" >/dev/null && echo "removed container $c"
    fi
done

if docker image inspect k8s-game/training >/dev/null 2>&1; then
    docker rmi k8s-game/training >/dev/null && echo "removed image k8s-game/training"
fi

if [ "${1:-}" = "--reset" ]; then
    rm -f progress.txt answers/*.txt data/visits.txt
    echo "reset progress, answers and data"
fi

echo "training ground is clean"
