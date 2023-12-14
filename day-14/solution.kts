#!/usr/bin/env kotlin

typealias Grid = List<CharArray>

fun displayGrid(grid: Grid): String {
  return grid.map { it.joinToString("") }.joinToString("\n")
}

data class Dim(val rows: Int, val cols: Int)
fun sizeOf(grid: Grid): Dim {
  return Dim(grid.size, grid.first().size)
}

fun sweep(grid: Grid): Grid {
  val sz = sizeOf(grid)
  val t = grid.map { it.copyOf() }

  for (col in 0..(sz.cols-1)) {
    var wall = 0
    for (row in 0..(sz.rows-1)) {
      when (t[row][col]) {
        '#' -> wall = row + 1
        'O' -> {
          t[row][col] = '.'
          t[wall][col] = 'O'
          wall++
        }
      }
    }
  }

  return t
}

fun score(grid: Grid): Int {
  val sz = sizeOf(grid)
  return grid.withIndex().fold(0) { sum, (idx, row) -> sum + (sz.rows - idx) * row.count { it == 'O' } }
}

// clockwise rotation bc sweeps go counterclockwise but our sweep is always north
// oops don't need 'times'
fun rotate(grid: Grid, times: Int): Grid {
  if (times <= 0) {
    return grid
  }

  val sz = sizeOf(grid)
  var t = List(sz.cols) { CharArray(sz.rows) { '.' } } // transposed

  for (row in 0..(sz.rows-1)) {
    for (col in 0..(sz.cols-1)) {
      t[col][sz.rows - row - 1] = grid[row][col]
    }
  }

  return rotate(t, times - 1)
}

fun sweepCycle(grid: Grid): Grid {
  val northed = sweep(grid)
  val wested = sweep(rotate(northed, 1))
  val southed = sweep(rotate(wested, 1))
  val easted = sweep(rotate(southed, 1))
  return rotate(easted, 1)
}

/////////////
//         //
// PART 1  //
//         //
/////////////

val input = generateSequence { readLine() }
val grid = input.map { it.toCharArray() }.toList()
// println(displayGrid(grid))
// println(sizeOf(grid))
// println("---")
// println(displayGrid(rotate(grid, 2)))

val swept = sweep(grid)
// println(displayGrid(swept))
println("Part 1 score = " + score(swept))

/////////////
//         //
// PART 2  //
//         //
/////////////

data class IndexedScore(val index: Int, val score: Int)
var hist = mutableMapOf<String, IndexedScore>()
var cur = 0
val cycle = 1_000_000_000

var g = grid
while (cur < cycle) {
  val str = displayGrid(g)
  if (str in hist) {
    val found = hist[str]!!
    val diff = cur - found.index
    if (diff > 0) {
      for (value in hist.values) {
        if (value.index >= found.index && value.index % diff == cycle % diff) {
          println("Part 2 score = " + value.score)
          break
        }
      }
    }
    break
  }
  hist[str] = IndexedScore(cur, score(g))
  g = sweepCycle(g)
  cur++
}
