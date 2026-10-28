# Level 0 solution

Do not read this before check.sh says you are done.

## The fault

The server binds to 127.0.0.1 inside the container. Docker's `-p 8080:8080` forwards host traffic to the container's own network interface (eth0), not to the container's loopback. Nothing listens on eth0, so the connection is reset.

Loopback inside a container is a separate loopback. It is only reachable by processes in that same container (or in the same network namespace, which is how Kubernetes sidecars share localhost later).

## How to see it

```
docker logs level-0                     # the app says it started, no error
docker exec level-0 netstat -tln        # Local Address is 127.0.0.1:8080, not 0.0.0.0:8080
docker exec level-0 cat /app/server.py  # HOST comes from BIND_HOST, default 127.0.0.1
```

## The fix

```
docker rm -f level-0
docker run -d --name level-0 -p 8080:8080 -e BIND_HOST=0.0.0.0 k8s-game/level-0
./check.sh
```

`--network host` also makes curl work, but it is a cheat: it removes the network namespace instead of fixing the bind address, and it does not exist in Kubernetes the same way.

## Why it matters for Kubernetes

A Pod has the same rule. A readiness probe and a Service both talk to the Pod IP, never to the Pod's loopback. An app that listens on 127.0.0.1 passes `docker build`, starts cleanly, and then fails every probe. This is one of the faults in level 2.
