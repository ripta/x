#!/usr/bin/env -S crystal run

curr = {0, 0}
shoe = {0, {0, 0}}

STDIN.each_line do |line|
  strdir, strdist, _ = line.split(' ')

  dir = case strdir
    when "L" then {-1,  0}
    when "R" then { 1,  0}
    when "U" then { 0, -1}
    when "D" then { 0,  1}
    else          { 0,  0}
  end
  dist = strdist.to_i()

  mov = {
    curr[0] + dist * dir[0],
    curr[1] + dist * dir[1],
  }

  shoe = {
    shoe[0] + dist, {
      shoe[1][0] + curr[0] * mov[1],
      shoe[1][1] + curr[1] * mov[0],
    },
  }
  #puts "#{dist} #{curr} #{mov} #{shoe}"

  curr = mov
end

inside = (shoe[1][0] - shoe[1][1]).abs() / 2.0
circ = shoe[0] / 2.0 + 1
area = inside + circ
puts "Part 1: #{area}"
