#!/usr/bin/env bash
# Builds the level 0 image and starts the broken container.
set -euo pipefail
cd "$(dirname "$0")"
docker rm -f level-0 >/dev/null 2>&1 || true
docker build -q -t k8s-game/level-0 .build >/dev/null
docker run -d --name level-0 -p 8080:8080 k8s-game/level-0 >/dev/null
echo "Level 0 is running as container 'level-0'."
echo "Goal: make 'curl http://localhost:8080' return the flag, then run ./check.sh"
