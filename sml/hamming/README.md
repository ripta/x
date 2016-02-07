# Hamming

Write a program that can calculate the Hamming difference between two DNA strands.

A mutation is simply a mistake that occurs during the creation or
copying of a nucleic acid, in particular DNA. Because nucleic acids are
vital to cellular functions, mutations tend to cause a ripple effect
throughout the cell. Although mutations are technically mistakes, a very
rare mutation may equip the cell with a beneficial attribute. In fact,
the macro effects of evolution are attributable by the accumulated
result of beneficial microscopic mutations over many generations.

The simplest and most common type of nucleic acid mutation is a point
mutation, which replaces one base with another at a single nucleotide.

By counting the number of differences between two homologous DNA strands
taken from different genomes with a common ancestor, we get a measure of
the minimum number of point mutations that could have occurred on the
evolutionary path between the two strands.

This is called the 'Hamming distance'.

It is found by comparing two DNA strands and counting how many of the
nucleotides are different from their equivalent in the other string.

    GAGCCTACTAACGGGAT
    CATCGTAATGACGGCCT
    ^ ^ ^  ^ ^    ^^

The Hamming distance between these two DNA strands is 7.

# Implementation notes

The Hamming distance is only defined for sequences of equal length. This means
that based on the definition, each language could deal with getting sequences
of equal length differently.

## Setup

You will need an SML interpreter to solve these problems. There are several popular implementations
[MLton](http://mlton.org/), [SML/NJ](http://www.smlnj.org/), and [PolyML](http://www.polyml.org/). For reference, the problems are being developed using PolyML.

## Testing Note: your problem implementation must be in a file named example.sml

1. cd into your problem directory
2. use the test_<problem-name>.sml file with the SML interpreter of your choice (3 listed above)
3. verify that the allTestsPass variable has a true value
   * if so, congrats
   * if not, something is wrong with your implementation of the problem (or the test cases :|)

#### Example:

     cd ~/exercism/xsml/accumulate
     poly
     Poly/ML 5.2 Release
     > use "test_accumulate.sml";
     val accumulate = fn : 'a list -> ('a -> 'b) -> 'b list
     val it = () : unit
     val test_cases =
         [([], fn, []), ([1, 2, 3], fn, [1, 4, 9]), ([1, 2, 3], fn, [1, 8, 27]),
          ([1, 2, 3], fn, [2, 3, 4]), ([1, 2, 3], fn, [0, 1, 2])]
      : (int list * (int -> int) * int list) list
     val allTestsPass = true : bool
     val run_tests = fn : ('a list * ('a -> ''b) * ''b list) list -> bool list
     val it = () : unit
     (* inspect allTestsPass variable for true or false*)

## Source

The Calculating Point Mutations problem at Rosalind [view source](http://rosalind.info/problems/hamm/)
