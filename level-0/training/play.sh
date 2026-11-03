#!/usr/bin/env bash
# Plays the training moves in order: ./play.sh [move number to start from]
# Shows a move, opens a shell for you to run its commands, checks the move
# when you type exit, and shows the next move when the check passes.
# Inside the shell: 'try' prints the move's commands, 'move' prints the move, 'check' leaves it and runs the check.
set -uo pipefail
cd "$(dirname "$0")"

last=5
start="${1:-}"
if [ -n "$start" ] && ! [[ "$start" =~ ^[1-5]$ ]]; then
    echo "usage: ./play.sh [move number 1-$last]"
    exit 2
fi

passed() { grep -q "^move $1 " progress.txt 2>/dev/null; }

next_move() {
    local n
    for n in $(seq 1 "$last"); do
        passed "$n" || { echo "$n"; return; }
    done
    echo $((last + 1))
}

done_all() {
    echo
    echo "All $last moves passed. Go fight the boss:"
    echo "  cd .. && cat README.md"
    exit 0
}

show() {
    echo
    echo "=================================================================="
    cat "moves/$1.md"
    echo "=================================================================="
}

rc=$(mktemp)
trap 'rm -f "$rc"' EXIT

shell_for() {
    {
        echo "[ -f ~/.bashrc ] && . ~/.bashrc"
        echo "MOVE_FILE='$PWD/moves/$1.md'"
        echo "PS1='\[\e[1;36m\][move $1]\[\e[0m\] \$ '"
        cat <<'EOF'
move() { cat "$MOVE_FILE"; }
try() { awk '/^## Try/{f=1;next} /^## /{if(f)exit} f{print}' "$MOVE_FILE"; }
check() { exit; }
EOF
    } > "$rc"
    echo
    echo ">>> Shell for move $1. Type 'try' to list its commands, 'move' to re-read it, 'check' when you are done."
    bash --rcfile "$rc" -i
}

n="${start:-$(next_move)}"
[ "$n" -gt "$last" ] && done_all

show "$n"
while :; do
    shell_for "$n"
    echo
    if ./check.sh "$n"; then
        n=$((n + 1))
        [ "$n" -gt "$last" ] && done_all
        echo
        read -rp "Press Enter for move $n, or q to quit: " ans || ans=q
        [ "$ans" = q ] && exit 0
        show "$n"
    else
        echo
        read -rp "Press Enter to go back to the shell, r to re-read move $n, or q to quit: " ans || ans=q
        case "$ans" in
            q) exit 0 ;;
            r) show "$n" ;;
        esac
    fi
done
