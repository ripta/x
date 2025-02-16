
https://www.nand2tetris.org/course

NAND logic

```
# NOT: IF A = 1 THEN 0 ELSE 1 ENDIF
Q = NOT A
  = A NAND A

# AND: IF A = 1 AND B = 1 THEN 1 ELSE 0 ENDIF
C = A NAND B
Q = A AND B
  = C NAND C

# OR
QA = A NAND A
QB = B NAND B
Q = A OR B
  = QA NAND QB

# NOR
Q = A NOR B
  = NOT (A OR B)

# XOR
C = A NAND B
QA = A NAND C
QB = B NAND C
Q = A XOR B
  = QA NAND QB

# MUX: IF S = 1 THEN A AND B ELSE A OR B ENDIF
QS = S NAND S
QBS = B NAND S
Q = (A AND NOT S) OR (B AND S)
  = (A AND QS) OR (QBS NAND QBS)
  = (A NAND QS) NAND 
```
