class Solution
  # 2906
  GRID_SIZE = 7
  def initialize(file:)
    @positions = file.readlines.map do |line|
      col, row = line.split(',')
      [col.to_i, row.to_i]
    end
  end

  def run
    distance = 0
    i = 0
    while !distance.nil?
      i += 1
      make_grid
      fill_grid(i)
      distance = walk_grid(0,0)
      puts "distance: #{distance} - i #{i}"
    end

    @positions[i]
  end

  def make_grid
    @grid = Array.new(GRID_SIZE) { Array.new(GRID_SIZE) { '.' } }
  end

  def fill_grid(bytes)
    @grid.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        if @positions.first(bytes).include?([col_index, row_index])
          @grid[row_index][col_index] = '#'
        end
      end
    end
  end

  def walk_grid(row, col)
    visited = Set.new
    queue = Queue.new
    # depth, row, col
    queue << [0, 0, 0]
    paths = []

    while !queue.empty? do
      depth, row, col = queue.pop(false)

      next if row < 0 || row >= @grid.length
      next if col < 0 || col >= @grid.first.length
      next if @grid[row][col] == '#'
      next if visited.include?([row, col])

      if [row, col] == [@grid.length - 1, @grid.length - 1]
        paths << depth
        next
      end

      visited << [row, col]

      queue << [depth + 1, row + 1, col]
      queue << [depth + 1, row - 1, col]
      queue << [depth + 1, row, col + 1]
      queue << [depth + 1, row, col - 1]
    end

    paths.min
  end

  def print_grid(visited)
    local_grid = Marshal.load(Marshal.dump(@grid))

    local_grid.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        if visited.include?([col_index, row_index])
          local_grid[row_index][col_index] = 'O'
        end
      end
    end

    puts local_grid.map {|g| g.join('') }
  end
end

file = File.new('./test_input.txt')
puts Solution.new(file: file).run
