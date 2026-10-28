#!/usr/bin/env bash
# Checks one training move: ./check.sh <1-5>
set -uo pipefail
cd "$(dirname "$0")"
n="${1:-}"
[ -z "$n" ] && { echo "usage: ./check.sh <move number 1-5>"; exit 2; }
pass() {
    echo "PASS move $n: $1"
    grep -q "^move $n " progress.txt 2>/dev/null || echo "move $n PASS $(date +%F)" >> progress.txt
    echo "XP: $(( $(grep -c PASS progress.txt) * 2 )) / 10"
    exit 0
}
fail() { echo "FAIL move $n: $1"; exit 1; }
running() { [ "$(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null)" = "true" ]; }

case "$n" in
1)
    docker image inspect k8s-game/training >/dev/null 2>&1 || fail "no image named k8s-game/training"
    for c in move1-a move1-b; do
        running "$c" || fail "container $c is not running"
        [ "$(docker inspect -f '{{.Config.Image}}' "$c")" = "k8s-game/training" ] || fail "$c is not from k8s-game/training"
    done
    pass "one image, two containers"
    ;;
2)
    running move1-a || fail "move1-a is not running"
    want=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' move1-a)
    got=$(head -1 answers/2.txt 2>/dev/null | tr -d '[:space:]')
    [ -n "$got" ] || fail "answers/2.txt is empty"
    [ "$got" = "$want" ] || fail "answers/2.txt says $got, which is not the IP of move1-a"
    pass "you can read a container from outside and inside"
    ;;
3)
    body=$(curl -s --max-time 3 http://localhost:8010) || fail "nothing answers on localhost:8010"
    echo "$body" | grep -q '^moves from' || fail "the greeting is not 'moves'. Got: $body"
    [ -f data/visits.txt ] || fail "data/visits.txt does not exist here, so /data is not mounted from this folder"
    docker inspect -f '{{range .Mounts}}{{.Destination}} {{end}}' move3 2>/dev/null | grep -q '/data' || fail "move3 has no mount on /data"
    pass "port, env and volume all arrived"
    ;;
4)
    a=$(sed -n 1p answers/4.txt 2>/dev/null | tr -d '[:space:]')
    b=$(sed -n 2p answers/4.txt 2>/dev/null | tr -d '[:space:]')
    [[ "$a" =~ ^[0-9]+$ && "$b" =~ ^[0-9]+$ ]] || fail "answers/4.txt needs two numbers on two lines"
    [ "$a" -ge 3 ] || fail "line 1 is the count after restarting move3 with the volume. It should have kept counting"
    [ "$b" -eq 1 ] || fail "line 2 is the count after restarting move4 without a volume. It should have started again"
    running move4 || fail "move4 is not running"
    [ "$(docker inspect -f '{{len .Mounts}}' move4)" = "0" ] || fail "move4 must run without any volume"
    pass "you know what survives a restart"
    ;;
5)
    [ -f answers/5.txt ] || fail "answers/5.txt is missing"
    line() { sed -n "${1}p" answers/5.txt | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]'; }
    [ "$(line 1)" = "5" ] || fail "line 1: count the FROM lines again"
    [ "$(line 2)" = "8.5" ] || fail "line 2: look at the FROM line of the build stage"
    [ "$(line 3)" = "build" ] || fail "line 3: find the COPY --from=frontend-build line and look up for the stage it is in"
    [ "$(line 4)" = "app-entrypoint" ] || fail "line 4: look for ENTRYPOINT"
    l5=$(line 5)
    { echo "$l5" | grep -q php && echo "$l5" | grep -q nginx; } || fail "line 5: the header comment says which two --target names are built"
    pass "you can read the scroll"
    ;;
*)
    echo "there is no move $n"; exit 2
    ;;
esac
