#!/usr/bin/env bash
#
# Poor man's quick run

set -euxo pipefail
ocamlfind ocamlopt -o solution \
  -g \
  -linkpkg -package containers \
  solution.ml

export OCAMLRUNPARAM=b
ulimit -s 32768
./solution
