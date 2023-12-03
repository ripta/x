#!/usr/bin/env julia

using Printf

function main()
  lines = readlines(stdin)
  grid = map(collect, lines)

  pt1 = 0

  row_count = length(grid)
  col_count = length(grid[1])

  part_numbers = Dict()
  for (row_num, row) in enumerate(grid)
    gear_locations = Set()

    curr_id = 0
    found_part = false
    for col_num in range(1, length(row)+2) # enumerate(row) # edge case for numbers ending on last col
      if col_num <= col_count && isdigit(row[col_num])
        cell = row[col_num]
        curr_id = curr_id * 10 + parse(Int, cell)

        for row_offset in [-1, 0, 1]
          row_check = row_num + row_offset
          if row_check < 1 || row_check > row_count
            continue
          end

          for col_offset in [-1, 0, 1]
            col_check = col_num + col_offset
            if col_check < 1 || col_check > col_count
              continue
            end

            check = grid[row_check][col_check]
            if !isdigit(check) && check != '.'
              found_part = true
            end

            if check == '*'
              push!(gear_locations, [row_check, col_check])
            end
          end
        end

      elseif curr_id > 0
        for gear in gear_locations
          if !haskey(part_numbers, gear)
            part_numbers[gear] = Vector()
          end

          push!(part_numbers[gear], curr_id)
        end

        if found_part
          pt1 += curr_id
        end

        curr_id = 0
        found_part = false
        gear_locations = Set()
      end
    end
  end

  # append!(part_numbers[[1, 1]], 2)
  # println(part_numbers)
  @printf("Part 1: %d\n", pt1)

  pt2 = 0
  for ids in values(part_numbers)
    if length(ids) != 2
      continue
    end

    pt2 += (ids[1] * ids[2])
  end

  @printf("Part 2: %d\n", pt2)
end

if abspath(PROGRAM_FILE) == @__FILE__
  main()
end
