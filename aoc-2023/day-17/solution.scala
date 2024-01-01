#!/usr/bin/env scala

import scala.collection.mutable.{HashMap, PriorityQueue, Set}
import scala.io.StdIn

@main def Solution() =
  val lines = Iterator.continually(StdIn.readLine()).takeWhile(_ != null)
  val grid = Grid(lines.toList.map(line => line.map(char => char.asDigit).toList))

  println("Pt1: " + traverse(grid, 1, 3))
  println("Pt2: " + traverse(grid, 4, 10))

case class Coord(row: Int, col: Int) {
  def +(that: Coord) = Coord(this.row + that.row, this.col + that.col)
  def -(that: Coord) = Coord(this.row - that.row, this.col + that.col)
  def *(fact: Int)   = Coord(this.row * fact,     this.col * fact)
  def in(grid: Grid) = this.row >= 0 && this.col >= 0 && this.row < grid.rows && this.col < grid.cols

  def flip = Coord(if this.row == 0 then 0 else -this.row, if this.col == 0 then 0 else -this.col)

  def isOnAxis(that: Coord) = this == that || this.flip == that
}

case class Grid(cells: List[List[Int]]) {
  val rows = this.cells.length
  val cols = this.cells.head.length

  def @@(c: Coord) = this.cells(c.row)(c.col)
}

case class HistEntry(row: Int, col: Int, from: Coord) extends Ordered[HistEntry] {
  import scala.math.Ordered.orderingToOrdered

  def compare(other: HistEntry): Int =
    (this.row, this.col, this.from.row, this.from.col) compare (other.row, other.col, other.from.row, other.from.col)

  override def toString(): String =
    "(" + this.row + ", " + this.col + ", " + this.from + ")"
}

val Left  = Coord( 0, -1)
val Right = Coord( 0,  1)
val Up    = Coord(-1,  0)
val Down  = Coord( 1,  0)

case class QueueEntry(dist: Int, row: Int, col: Int, from: Coord) extends Ordered[QueueEntry] {
  import scala.math.Ordered.orderingToOrdered

  def compare(other: QueueEntry): Int =
    (this.dist, this.row, this.col, this.from.row, this.from.col) compare (other.dist, other.row, other.col, other.from.row, other.from.col)

  def toCoord = Coord(this.row, this.col)
  def toHist  = HistEntry(this.row, this.col, this.from)

  override def toString(): String =
    "(" + this.row + ", " + this.col + ", " + this.from + ")"
}

def traverse(grid: Grid, mindist: Int, maxdist: Int): Int =
  val moves = List(Coord(0, -1), Coord(-1, 0), Coord(0, 1), Coord(1, 0)) // left, up, right, down
  val start = Coord(Int.MinValue, Int.MinValue)

  // scala pq is max-heap, so `reverse` to get min-heap
  val pq = PriorityQueue(QueueEntry(0, 0, 0, start)).reverse
  val seen = Set[HistEntry]()
  val dists: HashMap[HistEntry, Int] = HashMap()

  while pq.length > 0 do
    val e = pq.dequeue()
    if e.row >= grid.rows - 1 && e.col >= grid.cols - 1 then
      return e.dist
    if !seen.contains(e.toHist) then
      seen.add(e.toHist)
      for dir <- moves.filterNot(m => m.isOnAxis(e.from)) do
        var delta = 0
        for (newcoord, dist) <- Array.range(1, maxdist + 1)
                                .map(dist => (e.toCoord + dir * dist, dist))
                                .filter((c, d) => c in grid)
        do
          delta = delta + grid @@ newcoord
          if dist >= mindist then
            val newdist = e.dist + delta
            val newhist = HistEntry(newcoord.row, newcoord.col, dir)
            if dists.getOrElse(newhist, Int.MaxValue) > newdist then
              dists.put(newhist, newdist)
              pq.enqueue(QueueEntry(newdist, newcoord.row, newcoord.col, dir))

  return -1
