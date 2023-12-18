#!/usr/bin/env -S arch -x86_64 io
#
# io still needs x86 ^
#
# io is from https://iolanguage.org/reference/index.html

curr := list(0, 0)
shoelace := list(0, 0, 0)

File standardInput readLines foreach(line,
  segments := line split(" ")

  letter := segments at(2) exSlice(-2, -1)
  if(letter == "2") then(
    dir := list(-1, 0)
  ) elseif(letter == "0") then(
    dir := list(1, 0)
  ) elseif(letter == "3") then(
    dir := list(0, -1)
  ) elseif(letter == "1") then(
    dir := list(0, 1)
  ) else(
    dir := list(0, 0)
  )

  dist := segments at(2) exSlice(2, -2) fromBase(16)
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

inside := (shoelace at(1) - shoelace at(2)) abs / 2
circ := shoelace at(0) / 2 + 1
area := inside + circ
write("Pt2: ")
write(area asString(20, 0))
write("\n")
