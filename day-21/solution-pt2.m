#!/usr/bin/env -S octave-cli
#
# https://octave.sourceforge.io/octave/index.html
# https://octave.sourceforge.io/list_functions.php?sort=alphabetic

# r = radius
function expgrid = repgrid(grid, r)
  # m = 2*r;
  m = 2*r + 1 # repmat needs copy count

  [sr, sc] = find(grid == 'S');
  gridsz = size(grid);

  sani = grid;
  sani(sr, sc) = '.';  # only for one point

  expgrid = repmat(sani, m, m);
  expgrid(gridsz(1) * r + sr, gridsz(2) * r + sc) = 'S';
endfunction

args = argv();
filename = args{1}
iters = int64(base2dec(args{2}, 10))

gridcell = importdata(filename)
grid = char(gridcell);

gridsz = size(grid)
itermat = [idivide(iters, gridsz(1), "fix") rem(iters, gridsz(1))];

# maxdegree = 6
# maxdegree = 5 # 😬 still too large
# maxdegree = 4 # too negative
maxdegree = 3

# max walk reach in integer grids and partial grids
# maxwalk = gridsz(1) * (maxdegree - 1) + itermat(2)
maxwalk = gridsz(1) * maxdegree

#expgrid = repgrid(grid, itermat(1));
expgrid = repgrid(grid, maxdegree);

[rr, rc] = find(expgrid == '#');
rockpos = [rr, rc]; # |k,2|

[sr, sc] = find(expgrid == 'S');
startpos = [sr, sc]; # |1,2|

#             R    D     U    L
movemat = reshape([[0,1], [1,0], [-1,0], [0,-1]], 1, 2, 4);

hist = containers.Map("KeyType", "double", "ValueType", "any")
for idx = 1:maxwalk
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

# hist

pts = [];
for q = 1:maxdegree
  # x = gridsz(1) * q;
  x = gridsz(1) * (q - 1) + double(itermat(2));
  sz = size(hist(x));
  pts = [pts; [x sz(1)]];
endfor

jj = [];
for q = 1:maxwalk
  sz = size(hist(q));
  jj = [jj; [q sz(1)]];
endfor
jj

pts
coef = polyfit(pts(:, 1), pts(:, 2), maxdegree-1)
answer_pt2 = int64(polyval(coef, double(iters)))
