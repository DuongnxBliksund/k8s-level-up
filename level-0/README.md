# Level 0: the port that goes nowhere

Goes with week 1 of the Kubernetes learning plan. Docker only, no cluster.

This is the boss. Do the training ground in `training/` first (see `training/README.md`). Moves 2 and 3 are the ones you need here.

## Goal

Start the container, make `curl http://localhost:8080` return the flag, and make `./check.sh` pass.

## Start

```
./setup.sh
curl http://localhost:8080
```

The image builds and the container starts. The curl still fails. Find out why and fix it.

## Rules

- kubectl is not involved yet, but the same spirit applies: use `docker` commands only (logs, inspect, exec, ps). No reading `.build/` until check.sh passes.
- The level is worth 10 points. Each hint costs 1 point. Reveal them in order with `cat hints/1.md`, then `hints/2.md`, then `hints/3.md`.
- The fix must keep `-p 8080:8080` (the published port). A fix that removes the network boundary does not count.
- When check.sh passes, write the cause and the fix in your "why" notes file before you read `.build/SOLUTION.md`.

## Clean up

```
docker rm -f level-0
docker rmi k8s-game/level-0
```
