#!/usr/bin/env -S octave-cli --silent
#
# https://octave.sourceforge.io/octave/index.html
# https://octave.sourceforge.io/list_functions.php?sort=alphabetic

args = argv();
filename = args{1}
iters = int64(base2dec(args{2}, 10))

# gridcell = importdata("input-test-a.txt")
gridcell = importdata(filename)
grid = char(gridcell);

# rockpos = find(grid == '#')
[rr, rc] = find(grid == '#');
# idk how else to force array evaluation above
rockpos = [rr, rc]; # |k,2|

# startpos = find(grid == 'S')
[sr, sc] = find(grid == 'S');
startpos = [sr, sc]; # [[ 6 6 ]] - |1,2|

#             R    D     U    L
# movemat = [0,1; 1,0; -1,0; 0,-1] # nonconf - |2,2| vs |4,2|
movemat = reshape([[0,1], [1,0], [-1,0], [0,-1]], 1, 2, 4);

hist = containers.Map("KeyType", "double", "ValueType", "any")
for idx = 1:iters
  pos = startpos;  # |1,2|
  if (idx > 1)
    pos = hist(idx - 1);  # |n,2| n>1
  endif
  # idx

  endpos = pagetranspose(plus(pos, movemat));
  # endpossz = size(endpos)
  # |2,n,4| n>=1

  endposr = reshape(endpos, 2, prod(size(endpos)) / 2, 1);
  # endposrsz = size(endposr)
  # |2,4n| n>=1

  endposc = ctranspose(endposr);
  # endposcsz = size(endposc)
  # |4n,2| n>=1

  endposu = unique(endposc, "rows");
  # endposusz = size(endposu)
  # |m,2| 1<=m<=4n

  memberlog = ismember(endposu, rockpos, "rows");
  # |m,1|

  validpos = endposu(~memberlog, :);
  hist(idx) = validpos;
  # |p,2| 1<=p<=m<=4n   cf. pos = |n,2| n>1  OK
endfor

hist
sz = size(hist(iters));
answer_pt1 = sz(1)
