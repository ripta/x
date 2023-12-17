#!/usr/bin/env scala

import scala.collection.mutable.{HashMap, PriorityQueue, Set}
import scala.io.StdIn

@main def Solution() =
  val lines = Iterator.continually(StdIn.readLine()).takeWhile(_ != null)
  val grid = lines.toList.map(line => line.map(char => char.asDigit).toList)

  println("Pt1: " + traverse(grid, 1, 3))
  println("Pt2: " + traverse(grid, 4, 10))

case class HistEntry(row: Int, col: Int, from: Int) extends Ordered[HistEntry] {
  import scala.math.Ordered.orderingToOrdered

  def compare(other: HistEntry): Int =
    (this.row, this.col, this.from) compare (other.row, other.col, other.from)

  override def toString(): String =
    "(" + this.row + ", " + this.col + ", " + this.from + ")"
}

case class QueueEntry(dist: Int, row: Int, col: Int, from: Int) extends Ordered[QueueEntry] {
  import scala.math.Ordered.orderingToOrdered

  def compare(other: QueueEntry): Int =
    (this.dist, this.row, this.col, this.from) compare (other.dist, other.row, other.col, other.from)

  def toHist =
    HistEntry(this.row, this.col, this.from)

  override def toString(): String =
    "(" + this.row + ", " + this.col + ", " + this.from + ")"
}

def traverse(grid: List[List[Int]], mindist: Int, maxdist: Int): Int =
  val moves = List(List(0, -1), List(-1, 0), List(0, 1), List(1, 0)) // left, up, right, down
  val rows = grid.length
  val cols = grid.head.length

  // scala pq is max-heap, so `reverse` to get min-heap
  val pq = PriorityQueue(QueueEntry(0, 0, 0, -1)).reverse
  val seen = Set[HistEntry]()
  val dists: HashMap[(Int, Int, Int), Int] = HashMap()

  while pq.length > 0 do
    val e = pq.dequeue()
    if e.row >= rows - 1 && e.col >= cols - 1 then
      return e.dist
    if !seen.contains(e.toHist) then
      seen.add(e.toHist)
      for dir <- Array.range(0, 4) do
        var delta = 0
        if dir != e.from && (dir + 2) % 4 != e.from then
          for dist <- Array.range(1, maxdist + 1) do
            val newrow = e.row + moves(dir)(0) * dist
            val newcol = e.col + moves(dir)(1) * dist
            if newrow >= 0 && newcol >= 0 && newrow < rows && newcol < cols then
              delta = delta + grid(newrow)(newcol)
              if dist >= mindist then
                val newdist = e.dist + delta
                if dists.getOrElse((newrow, newcol, dir), Int.MaxValue) > newdist then
                  dists.put((newrow, newcol, dir), newdist)
                  pq.enqueue(QueueEntry(newdist, newrow, newcol, dir))

  return -1
