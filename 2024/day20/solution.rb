class Solution
  def initialize(file:)
    @grid = []
    @paths = Hash.new(0)

    file.readlines.each_with_index do |row, row_index|
      row_arr = []
      row.chomp.split('').each_with_index do |col, col_index|
        @start = [col_index, row_index] if col == 'S'
        @target = [col_index, row_index] if col == 'E'
        row_arr << col
      end

      @grid << row_arr
    end
    @cheats = Set.new
  end

  def run
    path = walk_grid(@grid)
    arr = make_path_array(path)

    cheats = []
    arr.each_with_index do |space_1, index|
      Array(arr[index + 3..]).each_with_index do |space_2, i|
        index_2 = index + 3 + i
        distance = manhattan_distance(space_2, space_1)
        if distance <= 20 && index_2 - index > distance
          puts index_2 - index - distance
          cheats << index_2 - index - distance
        end
      end
    end

    cheats.select { |c| c >= 100 }.count

    #@weights = make_reverse_depth(path)
    #puts @weights
    #return
    #walk_grid(@grid)

    #puts "num cheats: #{@cheats.length}"
    #scores = @cheats.map do |cheat|
    #  starting, ending = cheat
    #  cheat_score(starting, ending)
    #end

    #scores.select {|c| c >= 100 }.count
  end

  def cheat_score(starting, ending)
    starting_row, starting_col, = starting
    ending_row, ending_col = ending

    cheat_distance = manhattan_distance(starting, ending)

    @weights[[starting_row,starting_col]][:cost] - @weights[[ending_row,ending_col]][:cost] - cheat_distance
  end

  def manhattan_distance(p,q)
    p.zip(q).map{|u,v| (u-v).abs}.inject(:+)
  end

  def add_cheat_if_possible(row, col, last)
    last_row, last_col = last
    return if @weights[[last_row, last_col]].nil?
    cheat_origin_row = row
    cheat_origin_col = col

    cheat_tax = 1

    queue = [[cheat_tax, cheat_origin_row, cheat_origin_col]]
    visited = Set.new

    while !queue.empty? do
      cheat_tax, row, col = queue.sort_by! { |a| a.first }.shift
      next if out_of_bounds?(row, col)
      next if visited.include?([row, col])
      #next if edge?(row, col)
      next if cheat_tax > 20

      visited << [row, col]

      if ['.', 'E'].include?(@grid[row][col])
        if !@weights[[row,col]].nil? && cheat_score([last_row, last_col], [row,col]) >= 50
          @cheats << [[last_row, last_col], [row, col]]
        end
      end

      adjacent_spaces(row, col).each { |(adj_row, adj_col)| queue << [cheat_tax + 1, adj_row, adj_col]  }
    end

      #adjacent_spaces(row, col).each do |(adj_row, adj_col)|
      #  next if out_of_bounds?(adj_row, adj_col)
      #  next if edge?(adj_row, adj_col)
      #  next unless ['.','E'].include?(@grid[adj_row][adj_col])
      #  next if @weights[[adj_row,adj_col]].nil?

      #  cheat_score  = score - @weights[[adj_row,adj_col]][:cost].to_i - cheat_tax

      #  if cheat_score > 0
      #    @cheats << [cheat_score, [row, col], [adj_row, adj_col]]
      #  end
      #end
    #end
  end

  def walk_grid(grid)
    queue = []
    col, row = @start
    # depth, row, col, last_coords
    queue << [0, col, row, nil]
    visited = Set.new
    path = {}

    while !queue.empty? do
      depth, col, row, last  = queue.sort_by! { |a| a.first }.shift
      next if out_of_bounds?(row, col)

      if grid[row][col] == '#'
        if @weights
          add_cheat_if_possible(row, col, last)
        end
        next
      end

      next if visited.include?([row, col])

      path[[row, col]] = { depth: depth, last: last }

      if grid[row][col] == 'E'
        # found
        next
      end

      visited << [row, col]
      last = [row, col]

      queue << [depth + 1, col - 1, row, last]
      queue << [depth + 1, col, row - 1, last]
      queue << [depth + 1, col + 1, row, last]
      queue << [depth + 1, col, row + 1, last]
    end

    path
  end

  def make_path_array(path)
    arr = []
    col, row = @target

    key = [row, col]
    arr.unshift(key)

    hash = path[key]

    while !hash.nil?
      key = hash[:last]
      arr.unshift(key) if key
      hash = path[key]
    end

    arr
  end

  def make_reverse_depth(path)
    weights = {}
    col, row = @target

    key = [row, col]
    i = 0
    hash = path[key]

    while !hash.nil? do
      next_row, next_col = hash[:last]
      if next_row.nil?
        weights[key] = { cost: i, prev: nil }
        break
      end
      next_key = [next_row, next_col]
      weights[key] = { cost: i, prev: next_key }
      key = next_key
      hash = path[key]
      i += 1
    end

    weights
  end

  def out_of_bounds?(row, col)
    row < 0 || row >= @grid.first.length ||
      col < 0 || col >= @grid.length
  end

  def create_cheats
    cheat_coords = Set.new
    @cheats = {}
    i = 0
    j = 0
    @grid.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        j += 1
        puts "#{(@grid.first.length * @grid.length) - j} to go"
        if col == '#' && !edge?(row_index, col_index) &&
            !adjacents_all_blocked?(row_index, col_index) &&
            !cheat_coords.include?([row_index, col_index])
          adjacent_spaces(row_index, col_index).each do |(adj_row, adj_col)|
            next if edge?(adj_row, adj_col)
            if @grid[adj_row][adj_col] == '.'
              if !cheat_coords.include?([row_index, col_index])
                i += 1
                grid_dup = Marshal.load(Marshal.dump(@grid))
                grid_dup[row_index][col_index] = 1
                grid_dup[adj_row][adj_col] = 2
                @cheats[i] = grid_dup
                cheat_coords << [row_index, col_index]
              end
            end
          end
        end
      end
    end
  end

  def adjacents_all_blocked?(row, col)
    @grid[row - 1][col] == '#' &&
    @grid[row + 1][col] == '#' &&
    @grid[row][col - 1] == '#' &&
    @grid[row][col + 1] == '#'
  end

  def adjacent_spaces(row, col)
    [
      [row - 1, col],
      [row + 1, col],
      [row, col + 1],
      [row, col - 1],
    ]
  end

  def edge?(row, col)
    [0,@grid.first.length - 1].include?(row) || [0,@grid.length - 1].include?(col)
  end


  def print_grid(grid)
    puts grid.map { |row| row.join(' ') }
    puts "------------------------------"
  end
end

file = File.new('./input.txt')

puts Solution.new(file: file).run
