#!/usr/bin/env bash
# Checks whether level 0 is solved.
set -uo pipefail
out=$(curl -s --max-time 3 http://localhost:8080 2>&1) || true
if echo "$out" | grep -q "Level 0 complete"; then
    echo "PASS: $out"
    echo "Write the cause and the fix in your notes file, then open .build/SOLUTION.md to compare."
    exit 0
fi
echo "FAIL: no flag from http://localhost:8080"
docker ps --filter name=level-0 --format 'container level-0 is {{.Status}}' | grep . || echo "container level-0 is not running"
exit 1
