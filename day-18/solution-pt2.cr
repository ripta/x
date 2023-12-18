#!/usr/bin/env -S crystal run

curr = {0.to_i64(), 0.to_i64()}
shoe = {0.to_i64(), {0.to_i64(), 0.to_i64()}}

STDIN.each_line do |line|
  _, _, raw = line.split(' ')
  encoded = raw.lchop("(#").rchop(")")

  strdist = encoded[..4]
  strdir = encoded[5].to_s()

  dir = case strdir
    when "0" then { 1,  0}
    when "1" then { 0,  1}
    when "2" then {-1,  0}
    when "3" then { 0, -1}
    else          { 0,  0}
  end
  dist = strdist.to_i64(16)

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
puts "Part 2: #{area}"
