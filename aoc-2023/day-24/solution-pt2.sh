#!/usr/bin/env bash
#
# Entrypoint for solution pt2. Invoke like:
#
#   ./solution-pt2.sh < input-final.txt

set -euo pipefail

input="$1"

# Generate smt2 file
./solution-pt2.py < "$input" > "$input".smt2

# Execute smt2 file and pluck out the lisp sexps, cobble together an arithmetic
# expression, and pipe to `bc` with mathlib support 😅
z3 "$input".smt2 | grep '^(' | cut -f2 -w | tr -d ')' | paste -s -d+ - | bc -l
