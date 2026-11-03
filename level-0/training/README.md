# Week 1 training ground

Five moves, 2 XP each. Learn them in order, each one has a check. The boss (level 0, one folder up) needs moves 2 and 3.

1. `moves/1.md` image versus container
2. `moves/2.md` read the state: logs, inspect, exec
3. `moves/3.md` the three doors: -p, -e, -v
4. `moves/4.md` a container is throwaway
5. `moves/5.md` read the scroll: a production multi-stage Dockerfile

Training is open book: read `app/` and `scroll/` freely. Run every command from this folder. `./check.sh N` checks move N and records it in `progress.txt`.

Or let `./play.sh` drive: it shows a move, opens a shell for you to run its commands, checks the move when you type `check` (or `exit`), and shows the next move when the check passes. Inside that shell, `try` prints the move's commands and `move` prints the whole move again. It starts at your first unpassed move. `./play.sh 3` starts at move 3.

Clean up after the boss:

```
./cleanup.sh
```

This removes the training containers and image but keeps `progress.txt` and your answers. Run `./cleanup.sh --reset` to start the training from zero.
