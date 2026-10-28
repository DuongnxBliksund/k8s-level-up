# Week 1 training ground

Five moves, 2 XP each. Learn them in order, each one has a check. The boss (level 0, one folder up) needs moves 2 and 3.

1. `moves/1.md` image versus container
2. `moves/2.md` read the state: logs, inspect, exec
3. `moves/3.md` the three doors: -p, -e, -v
4. `moves/4.md` a container is throwaway
5. `moves/5.md` read the scroll: a production multi-stage Dockerfile

Training is open book: read `app/` and `scroll/` freely. Run every command from this folder. `./check.sh N` checks move N and records it in `progress.txt`.

Clean up after the boss:

```
docker rm -f move1-a move1-b move3 move4
docker rmi k8s-game/training
```
