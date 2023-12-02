#!/usr/bin/env racket

#lang racket

(define (integer-digit c)
  ; if c is a numeric char, then subtract the codepoint for '0' to get its digit value
  (and (char-numeric? c)
       (- (char->integer c) (char->integer #\0))
  ))

(define (word-digit s i)
  (define word-regexps
    (for/list ([word (in-list '(zero one two three four five six seven eight nine))])
      (regexp (format "^~a" word))))
  (or
   (for/first
     ([(rx n)
       (in-indexed (in-list word-regexps))]
      #:when (regexp-match? rx s i))
     n)
   (integer-digit (string-ref s i))))

(define (parse-value s)
  ; find first digit from left
  (define fval
    (for/fold ([acc #f]) ([i (in-range 0 (string-length s))])
      (define digit (word-digit s i))
      (or acc digit)))
  ; find first digit from right
  (define lval
    (for/foldr ([acc #f]) ([i (in-range 0 (string-length s))])
      (define digit (word-digit s i))
      (or acc digit)))
  ; value = fval * 10 + lval
  (+ (* fval 10) lval))

(printf "~a~n"
  (for/sum ([line (in-lines (current-input-port) 'any)])
    (parse-value line)))
