#!/usr/bin/env bash

set -euxo pipefail

pt="$1"
input="$2"

if [[ "$pt" == *"1"* ]]; then
  if [[ "$input" == *final* ]]; then
    ./solution-${pt}.m "$input" 64
  else
    ./solution-${pt}.m "$input" 6
  fi
else
  ./solution-${pt}.m "$input" 26501365
fi
