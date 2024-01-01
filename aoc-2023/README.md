# Advent of Code 2023

Solutions for [Advent of Code 2023](https://adventofcode.com/2023/). For
funsies, I chose a different language on most days. A few days repeat, but then
get re-solved later in the day or week in a different language.

I avoided various languages, because I either use it for $work a lot (e.g., Go)
or have been using it for personal projects (e.g., writing an [operating system
in Rust](https://os.phil-opp.com/)).

Most languages came with a pre-AoC study session, even ones I was already
familiar with. Broad strokes: read from STDIN, write to STDOUT, looping
constructs, functions, ADTs, structs, expectation-breaking conventions (e.g.,
1-based indexing).

Since Part Ⅱ of each day somewhat builds on top of Part	Ⅰ, I didn't always
remember to not overwrite the first solution. Some solutions are as-submitted,
and others are cleaned up. I make no guarantees on the usefulness of these
source files, and I certainly can't claim they're idiomatic.

From the git commit logs, for a total of 27 distinct languages, they are:

```
day-01: racket v8.10
day-02: sml/nj v110.99.4
day-03: julia v1.9
day-04: perl v5.38.2
        idris2 v0.6.0
day-05: escript (erlang v25.3.2.7)
day-06: arturo v0.9.83
day-07: nim v2.0.0 (2023-08-01)
day-08: swift v5.9.1
day-09: haskell lts-21.24 (ghc-9.4.8)
day-10: (oops, sources missing?) f# 6.0.7
day-11: Rscript / R 4.3.2 (2023-10-31)
day-12: ocaml 4.14.0 / opam 2.1.5
day-13: zig 0.11
day-14: kotlin 1.9.20 / jre 19.0.2+7
day-15: perl v5.38.2
        lua v5.1
        (pt1 only) factor v0.99
day-16: clojure v1.11.1.1413
day-17: scala v3.3.1 / jre 19.0.2+7
day-18: crystal v1.9.2 / llvm 15.0.7
        io v2017.09.06_1
day-19: typescript / bun v1.0.18
day-20: gleam v0.32.4
day-21: octave v8.4.0
day-22: raku v6.d / rakudo v2023.08
day-23: dlang / dmd v2.105.3
day-24: python v3.11.6, smtlib v4.12.4, bc v4.0.2, bash
day-25: python v3.11.6 / networkx v3.2.1
```

I may revisit some broken ones if I get bored post-holiday. Or not, because
there are other interesting things I could do too. I have thoughts about almost
every language above, but some highlights:

* I really like Erlang, but I like its virtual machine (BEAM) even more. Erik
  Stenman's [The Beam Book](https://blog.stenmans.org/theBeamBook/) is on my
  list of readings. I think it's interesting that the assembler encodes
  [unsigned integers less than 16][beam16] into the top four bits of the opcode.

[beam16]: https://github.com/erlang/otp/blob/922ef22d58ae5232fcb2a44776d9879e8433d71d/lib/compiler/src/beam_asm.erl#L553

* The one stack-oriented (concatenative) language I used (Factor on day-15) is
  one I'd love to try wielding again, though it will require dedicated time.

* Around week two, I tried to reïmplement day-01 in an array-oriented language
  (UIUA, not captured in the list above), and got maybe half-way through the
  first part before it broke my brain enough that I had to step back. Maybe
  I'll attempt it again; I never struggled nearly this much with R and Octave /
  MATLAB.

* Apropos of nothing, I learned that less than one in five programmers that use
  MATLAB want to use it again next year (vid. [StackOverflow survey][so-surv]).

[so-surv]: https://survey.stackoverflow.co/2023/

* I like to joke that Perl was my first (programming language) love. Raku (neé
  Perl 6) seemed different enough from Perl. But the more I used it, the more
  evident its sigil-laden Perl roots. (A negative for others, I'm sure.) Just
  gonna leave `postcircumfix:<{; }>(%seen, @idxs)[0]` here.

* Working on the problems, it's evident that Python's rich libraries match so
  well with the types of puzzles. It's clear why [about four out of ten
  solvers][aoc-surv] chose to use Python 3. Being able to call `itertools` when
  you need combinations, or `networkx` when you need minimum cut, or even just
  `@cache` from `functools` instead of hand-rolling your own is underrated.

[aoc-surv]: https://jeroenheijmans.github.io/advent-of-code-surveys/

* Anecdotally, I didn't run into any off-by-one errors. I did run into off-by-two
  errors a few times.

* I love clojure thread first `->` and thread last `->>` macros. I love macros.
  I also love the ability to ask about macro expansion.

  ```clojure
  user=> (macroexpand '(->> 1 (+ 2) (* 3)))
  (* 3 (+ 2 1))

  user=> (macroexpand '(-> 1 (+ 2) (* 3)))
  (* (+ 1 2) 3)
  ```

* I get alarmingly far by relying on syntax highlighting in my text editor of
  choice. Is it `elseif`, `elsif`, or `elif`? Just start removing characters
  until syntax highlighting says you're right. (Well, `else if` is trickier,
  and I use LSP to tell me if I'm way off base.)
