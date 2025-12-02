class Solution
  ROWS = 103
  COLUMNS = 101
  ITERATIONS = 10000

  def initialize(file:)
    @grid = Array.new(ROWS) { Array.new(COLUMNS) { '.' } }
    @pieces = {}
    i = 0
    file.readlines.each do |line|
      position, velocity = line.split(' ')
      @pieces[i] = {
        # col, row
        position: position.split('=').last.split(',').map(&:to_i),
        velocity: velocity.split('=').last.split(',').map(&:to_i),
      }
      i += 1
    end
    @quad_and_safety = quandrant_ranges
  end

  def run
    i = 1
    ITERATIONS.times do
      @pieces.each do |piece_number, piece_hash|
        move(piece_hash)
      end
      variance(i)
      i += 1
    end

    calc_safety
    @quad_and_safety.each.inject(1) do |acc, hash|
      acc * hash[:safety]
    end
  end

  def variance(i)
    row_sum = 0
    col_sum = 0
    @pieces.each do |_, piece_hash|
      col, row = piece_hash[:position]
      row_sum += row
      col_sum += col
    end

    row_mean = row_sum.to_f / @pieces.length
    col_mean = col_sum.to_f / @pieces.length
    row_square_diff = 0
    col_square_diff = 0

    @pieces.each do |_, piece_hash|
      col, row = piece_hash[:position]
      col_square_diff += (col - col_mean) ** 2
      row_square_diff += (row - row_mean) ** 2
    end

    row_variance = row_square_diff / @pieces.length
    col_variance = col_square_diff / @pieces.length

    if row_variance == 317.5835999999997 && col_variance == 358.11942400000055
      print_grid
    end

    file = File.open('./variances.txt','a+')
    file.write("#{[row_variance,col_variance,i]}\n")
  end

  def calc_safety
    @pieces.each do |piece_number, piece_hash|
      col, row = piece_hash[:position]
      found_quad = @quad_and_safety.find { |h| h[:coords][:row].cover?(row) && h[:coords][:col].cover?(col) }
      if found_quad
        found_quad[:safety] += 1
      end
    end
  end

  def quandrant_ranges
    # q1 q2
    # q4 q3
    # excludes middle rows
    q_1 = {
      row: (0..(ROWS / 2) - 1) ,
      col: (0..(COLUMNS / 2) - 1)
    }
    q_2 = {
      row: (0..(ROWS / 2) - 1),
      col: (((COLUMNS / 2) + 1 )..(COLUMNS - 1))
    }
    q_3 = {
      row: (((ROWS / 2) + 1)..(ROWS - 1)),
      col: (((COLUMNS / 2) + 1)..(COLUMNS - 1))
    }
    q_4 = {
      row: (((ROWS / 2) + 1)..(ROWS - 1)),
      col: (0..(COLUMNS / 2) - 1)
    }
    [
      { coords: q_1, safety: 0 },
      { coords: q_2, safety: 0 },
      { coords: q_3, safety: 0 },
      { coords: q_4, safety: 0 }
    ]
  end

  def update_grid_with_quandrant(quadrant)
    quadrant[:row].each do |row_index|
      quadrant[:col].each do |col_index|
        @grid[row_index][col_index] = 'X'
      end
    end
  end

  def move(piece_hash)
    starting_col, starting_row = piece_hash[:position]
    #puts "starting: #{starting_row} #{starting_col}"
    move_col, move_row = piece_hash[:velocity]
    #puts "velocity: #{move_row} #{move_col}"
    next_col = (starting_col + move_col) % COLUMNS
    next_row = (starting_row + move_row) % ROWS

    #puts "moving to: #{next_row} #{next_col}"
    piece_hash[:position] = [next_col, next_row]
  end

  def print_grid
    local_grid = Marshal.load(Marshal.dump(@grid))
    @pieces.each do |piece_number, hash|
      col, row = hash[:position]
      local_grid[row][col] = 'X'
    end

    puts local_grid.map { |c| c.join(' ') }
    puts "-" * COLUMNS
  end
end

file = File.new('./input.txt')
puts Solution.new(file: file).run
