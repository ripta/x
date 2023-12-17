USING: io kernel math prettyprint sequences splitting ;
IN: solution

!
! Useful tutes:
!
! https://andreaferretti.github.io/factor-tutorial/
! https://github.com/bjourne/playground-factor/wiki/Tips-and-Tricks-Filesystem#tailing-a-file
!

: slurp-words ( -- seq ) read-lines [ "," split ] map concat ;

: hasher ( string -- n ) 0 [ + 17 * 256 mod ] reduce ;
: pt1 ( seq -- n ) [ hasher ] map-sum ;

: start ( -- ) slurp-words pt1 . ;
MAIN: start
