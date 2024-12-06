class Solution
  UP = 'up'
  DOWN = 'down'
  LEFT = 'left'
  RIGHT = 'right'
  def initialize(file:)
    @grid = file.readlines.map { |l| l.chomp.chars }
  end

  def run
    counter = 0
    other_counter = 0
    (0..@grid.length - 1).each do |i|
      (0..@grid.first.length - 1).each do |j|
        other_counter += 1
        grid = Marshal.load(Marshal.dump(@grid))
        grid[i][j] = 'O' if grid[i][j] == '.'
        puts "walking grid: #{other_counter}"
        if !walk_grid(grid: grid)
          counter += 1
        end
      end
    end
    counter
  end

  def walk_grid(grid:)
    char, starting_coords = start(grid: grid)
    orientation = starting_position(char: char)
    row, col = starting_coords
    visited = Set.new
    visited << [row, col, orientation]
    step = 0
    while true do
      move_row, move_col = move(current_orientation: orientation)
      next_row = row + move_row
      next_col = col + move_col
      break if next_row < 0 || next_row >= grid.first.length || next_col < 0 || next_col >= grid.length

      if ['#', 'O'].include?(grid[next_row][next_col])
        orientation = change_orientation(orientation: orientation)
      else
        row = next_row
        col = next_col
        if visited.include?([row, col, orientation])
          # in a loop
          return false
        end
        visited << [row, col, orientation]
      end
    end
    visited.length
  end

  def start(grid:)
    grid.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        if col != '.' && col != '#' && col != 'O'
          return [col, [row_index, col_index]]
        end
      end
    end
  end

  def move(current_orientation:)
    case current_orientation
    when UP
      [-1, 0]
    when RIGHT
      [0, 1]
    when DOWN
      [1, 0]
    when LEFT
      [0, -1]
    end
  end

  def change_orientation(orientation:)
    case orientation
     when UP
       RIGHT
     when RIGHT
       DOWN
     when DOWN
       LEFT
     when LEFT
       UP
     end
  end

  def starting_position(char:)
    case char
    when '^'
      UP
    when 'v'
      DOWN
    when '>'
      RIGHT
    when '<'
      LEFT
    end
  end
end

file = File.open('./input.txt')

puts Solution.new(file: file).run
