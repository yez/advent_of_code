class PriorityQueue
  attr_reader :que, :cmp

  def initialize(&block)
    @que = []
    @cmp = block || ->(x, y) { (x <=> y) == -1 }
  end

  def size
    @que.size
  end

  def empty?
    @que.empty?
  end

  def inspect
    "<#{self.class}: size=#{size}, top=#{top || 'nil'}>"
  end

  def push(ele)
    @que << ele
    reheap(@que.size - 1)
    self
  end

  alias << push

  def pop
    return nil if empty?

    @que.pop
  end

  def peek
    return nil if empty?

    @que.last
  end

  def reheap(k)
    return self if size <= 1

    que = @que.dup

    v = que.delete_at(k)
    i = binary_index(que, v)

    que.insert(i, v)

    @que = que

    self
  end

  def binary_index(que, target)
    upper = que.size - 1
    lower = 0

    while upper >= lower
      idx  = lower + (upper - lower) / 2
      comp = @cmp.call(target, que[idx])

      case comp
      when 0, nil
        return idx
      when 1, true
        lower = idx + 1
      when -1, false
        upper = idx - 1
      end
    end
    lower
  end
end

class Solution
  def initialize(file:)
    @grid = []
    @scores = []
    @visits = []
    file.readlines.each_with_index do |row, row_index|
      row_chars = row.split('')
      row_chars.each_with_index do |col, col_index|
        @start = [row_index, col_index] if col == 'S'
      end

      @grid << row_chars
    end
  end

  def run
    bfs(@start[0], @start[1])
    #find_target(@start[0], @start[1])

   # puts @scores.sort.map { |c| c.join(',') }
  end

  def bfs(row, col, queue = PriorityQueue.new)
    queue << [0, row, col, 'E']
    cost_hash = { [row, col, 'E'] => 0 }
    best = nil
    path = {}
    backtrack = []

    while !queue.empty? do
      score, row, col, orientation = queue.pop
      key = [row, col, orientation]

      next if !best.nil? && score > best

      if @grid[row][col] == 'E'
        best = score
        backtrack << key
      end

      right_turn_row, right_turn_col, right_turn_orientation = make_turn(orientation, 'right', row, col)
      left_turn_row, left_turn_col, left_turn_orientation = make_turn(orientation, 'left', row, col)
      forward_row, forward_col = move_forward(orientation, row, col)

      [
        [score + 1000 + 1, right_turn_row, right_turn_col, right_turn_orientation],
        [score + 1000 + 1, left_turn_row, left_turn_col, left_turn_orientation],
        [score + 1, forward_row, forward_col, orientation]
      ].each do |next_move|
        next_key = [next_move[1],next_move[2],next_move[3]]
        next_cost = next_move[0]

        next if @grid[next_move[1]][next_move[2]] == '#'

        if !cost_hash.key?(next_key) || cost_hash[next_key] > next_cost
          cost_hash[next_key] = next_cost
          queue << next_move
          path[next_key] = [key]
        elsif cost_hash[next_key] == next_cost
          path[next_key] << key
        end
      end
    end

    spaces = Set.new
    while !backtrack.empty?
      key = backtrack.pop
      puts "key: #{key}"
      spaces << [key[0], key[1]]
      backtrack.concat(path[key]) unless path[key].nil?
    end

    " output: #{[best, spaces.size]}"
  end

  def find_target(row, col, score = 0, current_orientation = 'E', visited = Set.new, steps = 0)
    return Float::INFINITY if visited.include?([row, col])

    if @grid[row][col] == 'E'
      @visits << visited
      puts "steps: #{ steps }, score: #{score}"
      print_grid(visited)
      return score
    end

    if @grid[row][col] == '#'
      visited << [row, col]
      return Float::INFINITY
    end

    visited << [row, col]

    #print_grid(visited)
    right_turn_row, right_turn_col, right_turn_orientation = make_turn(current_orientation, 'right', row, col)
    left_turn_row, left_turn_col, left_turn_orientation = make_turn(current_orientation, 'left', row, col)
    forward_row, forward_col = move_forward(current_orientation, row, col)

    [find_target(right_turn_row, right_turn_col, score + 1000 + 1, right_turn_orientation, visited.clone, steps + 1),
     find_target(left_turn_row, left_turn_col, score + 1000 + 1, left_turn_orientation, visited.clone, steps + 1),
      find_target(forward_row, forward_col, score + 1, current_orientation, visited, steps + 1)].min
  end

  def make_turn(current_orientation, turn_direction, row, col)
    case [current_orientation, turn_direction]
    when ['N', 'left'] # go west
      [row, col - 1, 'W']
    when ['N', 'right'] # go east
      [row, col + 1, 'E']
    when ['E', 'left'] # go north
      [row - 1, col, 'N']
    when ['E', 'right'] # go south
      [row + 1, col, 'S']
    when ['S', 'left'] # go east
      [row, col + 1, 'E']
    when ['S', 'right'] # go west
      [row, col - 1, 'W']
    when ['W', 'left'] # go south
      [row + 1, col, 'S']
    when ['W', 'right'] # go north
      [row - 1, col, 'N']
    end
  end

  def move_forward(current_orientation, row, col)
    case current_orientation
    when 'N'
      [row - 1, col]
    when 'E'
      [row, col + 1]
    when 'S'
      [row + 1, col]
    when 'W'
      [row, col - 1]
    end
  end

  def print_grid(visited)
    sleep 0.01
    local_grid = Marshal.load(Marshal.dump(@grid))

    visited.each do |visit|
      local_grid[visit.first][visit.last] = 'O'
    end

    puts local_grid.map { |c| c.join(' ') }
  end
  puts "-------------------------------------------------"
end

file = File.new('./input.txt')

puts Solution.new(file: file).run

