#!/usr/bin/env bash

set -euxo pipefail

input="$1"

if [[ "$input" == *final* ]]; then
  ./solution-pt1.py 200000000000000 400000000000000 < "$input"
else
  ./solution-pt1.py 7 27 < "$input"
fi
