#!/usr/bin/env -S arch -x86_64 io
#
# io still needs x86 ^
#
# io is from https://iolanguage.org/reference/index.html

curr := list(0, 0)
shoelace := list(0, 0, 0)

File standardInput readLines foreach(line,
  segments := line split(" ")

  letter := segments at(0)
  if(letter == "L") then(
    dir := list(-1, 0)
  ) elseif(letter == "R") then(
    dir := list(1, 0)
  ) elseif(letter == "U") then(
    dir := list(0, -1)
  ) elseif(letter == "D") then(
    dir := list(0, 1)
  ) else(
    dir := list(0, 0)
  )

  dist := segments at(1) asNumber
  move := list(
    curr at(0) + dist * dir at(0),
    curr at(1) + dist * dir at(1)
  )

  shoelace = list(
    shoelace at(0) + dist,
    shoelace at(1) + curr at(0) * move at(1),
    shoelace at(2) + curr at(1) * move at(0)
  )

  curr = move
)

inside := (shoelace at(1) - shoelace at(2)) abs / 2.0
circ := shoelace at(0) / 2.0 + 1
area := inside + circ
write("Pt1: #{area}\n" interpolate)
