#!/usr/bin/env Rscript

if (!require('base')) {
  install.packages('base')
  library('base')
}

# display wide numbers
options(scipen=99999999L)

# read from stdin
stdin <- file('stdin')
open(stdin, blocking=TRUE)
raw <- readLines(stdin)

# split multiline input into matrix of chars
map <- do.call(cbind, strsplit(raw, ''))

# figure out which rows are empty (no '#') and which cols are empty '#'
emptyRowIdx <- which(rowSums(map == '#') == 0)
emptyColIdx <- which(colSums(map == '#') == 0)
# print(c(emptyRowIdx, emptyColIdx))

# (row, col) coordinates of galaxies
galaxy_coords <- which(map == '#', arr.ind=TRUE)

# assign a numeric ID to each galaxy so we can find combinations
galaxies <- cbind(id=seq(nrow(galaxy_coords)), galaxy_coords)
#print(galaxies)

# calculate combination of size 2 of all galaxy IDs
# shape of pairs is 2, 3, #
#   dim 1 = 2 = galaxy_1, galaxy_2
#   dim 2 = 3 = id, row, col
#   dim 3 = count of all pairs, e.g., 36 for 9 galaxies
pairs <- combn(galaxies[,"id"], 2, function(id) galaxies[id,])
#print(dim(pairs))

# dim "3" is the dimension of pairs
manhattanDist <- apply(pairs, 3, function(pair) abs(pair[1, 2] - pair[2, 2]) + abs(pair[1, 3] - pair[2, 3]))
#print(manhattanDist)

# i love fudge
fudgeFactor <- apply(pairs, 3, function(pair) {
  # ,2 = rows
  rowFudge <- length(emptyRowIdx[emptyRowIdx %in% pair[1, 2]:pair[2, 2]])
  # ,3 = cols
  colFudge <- length(emptyColIdx[emptyColIdx %in% pair[1, 3]:pair[2, 3]])

  rowFudge + colFudge
})
#print(fudgeFactor)

print(sum(manhattanDist + fudgeFactor))
print(sum(manhattanDist + fudgeFactor * (10 - 1)))
print(sum(manhattanDist + fudgeFactor * (100 - 1)))
print(sum(manhattanDist + fudgeFactor * (1000000 - 1)))

# [1] 10231178
# [1] 15208074
# [1] 71198154
# [1] 622120986954
