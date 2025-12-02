class Solution
  def initialize(file:)
    @grid = []
    @moves = []
    reading_moves = false
    file.readlines.each do |line|
      chomped = line.chomp
      if !reading_moves
        if line.chomp.empty?
          reading_moves = true
          next
        end
        arr = []
        chomped.split('').each do |c|
          if c == 'O'
            arr << '['
            arr << ']'
          elsif c == '@'
            arr << '@'
            arr << '.'
          else
            2.times { arr << c }
          end
        end
        @grid << arr
      else
        @moves << chomped.split('')
      end
    end

    @moves.flatten!

    find_robot
  end

  def find_robot
    @grid.each_with_index do |row, row_index|
      row.each_with_index do |c, col_index|
        if c == '@'
          @robot = [row_index, col_index]
          return
        end
      end
    end
  end

  def run
    # if can move
    #   if next_move_box?
    #     shift boxes
    #       move
    #   else
    #     move
    #   end
    # end
    # next

    @moves.each do |move|
      row, col = @robot
      #puts "robot at:#{row},#{col}"

      if can_move?(move, row, col)
        ##puts "moving: #{move}"
        if next_move_box?(move, row, col)
          ##puts "shifting boxes"
          shift_boxes(move, row, col)
        end

        # replace robot with a dot
        @grid[row][col] = '.'
        # new robot
        @robot = move(move, row, col)
        #puts "new robot: #{@robot}"
        # add robot to grid
        @grid[@robot[0]][@robot[1]] = '@'
      end
      print_grid
    end

    cost
  end

  def shift_boxes(char, start_row, start_col)
    if char == '<' || char == '>'
      coords = []
      swap_row, swap_col = move(char, start_row, start_col)
      next_row, next_col = move(char, swap_row, swap_col)
      coords << [next_row, next_col]
      until @grid[next_row][next_col] == '.'
        next_row, next_col = move(char, next_row, next_col)
        coords << [next_row, next_col]
      end

      @grid[swap_row][swap_col] = '.'
      #puts "coords to swap: #{coords}"
      coords.each_slice(2) do |coord_slice|
        if char == '<'
          @grid[coord_slice[0][0]][coord_slice[0][1]] = ']'
          @grid[coord_slice[1][0]][coord_slice[1][1]] = '['
        elsif char == '>'
          @grid[coord_slice[0][0]][coord_slice[0][1]] = '['
          @grid[coord_slice[1][0]][coord_slice[1][1]] = ']'
        end
      end
    elsif char == '^'
      row, col = move(char, start_row, start_col)
      movable_boxes = adjacent_moveable_boxes_up(row, col)
      #puts movable_boxes
      # clear where the boxes are
      movable_boxes.each do |box_hash|
        box_left_row, box_left_col = box_hash[:left]
        box_right_row, box_right_col = box_hash[:right]
        @grid[box_left_row][box_left_col] = '.'
        @grid[box_right_row][box_right_col] = '.'
      end

      # redraw boxes
      movable_boxes.each do |box_hash|
        box_left_row, box_left_col = box_hash[:left]
        box_right_row, box_right_col = box_hash[:right]
        @grid[box_left_row - 1][box_left_col] = '['
        @grid[box_right_row - 1][box_right_col] = ']'
      end
    elsif char == 'v'
      row, col = move(char, start_row, start_col)
      movable_boxes = adjacent_moveable_boxes_down(row, col)
      #puts movable_boxes
      # clear where the boxes are
      movable_boxes.each do |box_hash|
        box_left_row, box_left_col = box_hash[:left]
        box_right_row, box_right_col = box_hash[:right]
        @grid[box_left_row][box_left_col] = '.'
        @grid[box_right_row][box_right_col] = '.'
      end

      # redraw boxes
      movable_boxes.each do |box_hash|
        box_left_row, box_left_col = box_hash[:left]
        box_right_row, box_right_col = box_hash[:right]
        @grid[box_left_row + 1][box_left_col] = '['
        @grid[box_right_row + 1][box_right_col] = ']'
      end

    end
  end

  def adjacent_moveable_boxes_up(row, col, boxes = Set.new)
    # find all touching boxes
    # if up, see move all row -1 if possible
    # if down move all row + 1 if possible
    #
    # could be that gaps close/open with the moves

    queue = Queue.new
    queue << build_box(row, col)

    while !queue.empty? do
      box = queue.pop(false)
      up_left_row = box[:left][0] - 1
      up_left_col = box[:left][1]
      if !out_of_bounds?(up_left_row, up_left_col) && next_move_box?('^', box[:left][0], box[:left][1])
        queue << build_box(up_left_row, up_left_col)
      end

      up_right_row = box[:right][0] - 1
      up_right_col = box[:right][1]
      if !out_of_bounds?(up_right_row, up_right_col) && next_move_box?('^', box[:right][0], box[:right][1])
        queue << build_box(up_right_row, up_right_col)
      end

      return [] if @grid[box[:left][0] - 1][box[:left][1]] == '#' || @grid[box[:right][0] - 1][box[:right][1]] == '#'

      # can move up
      boxes << box
    end

    boxes
  end

  def adjacent_moveable_boxes_down(row, col, boxes = Set.new)
    # find all touching boxes
    # if up, see move all row -1 if possible
    # if down move all row + 1 if possible
    #
    # could be that gaps close/open with the moves

    queue = Queue.new
    queue << build_box(row, col)

    while !queue.empty? do
      box = queue.pop(false)
      up_left_row = box[:left][0] + 1
      up_left_col = box[:left][1]
      if !out_of_bounds?(up_left_row, up_left_col) && next_move_box?('v', box[:left][0], box[:left][1])
        queue << build_box(up_left_row, up_left_col)
      end

      up_right_row = box[:right][0] + 1
      up_right_col = box[:right][1]
      if !out_of_bounds?(up_right_row, up_right_col) && next_move_box?('v', box[:right][0], box[:right][1])
        queue << build_box(up_right_row, up_right_col)
      end

      return [] if @grid[box[:left][0] + 1][box[:left][1]] == '#' || @grid[box[:right][0] + 1][box[:right][1]] == '#'

      # can move up
      boxes << box
    end

    boxes
  end

  def build_box(row, col)
    if @grid[row][col] == '['
      {
        left: [row, col],
        right: [row, col + 1]
      }
    elsif @grid[row][col] == ']'
      {
        left: [row, col - 1],
        right: [row, col]
      }
    end
  end

  def next_move_box?(char, row, col)
    next_row, next_col = move(char, row, col)
    ['[', ']'].include?(@grid[next_row][next_col])
  end

  def out_of_bounds?(row, col)
    row < 0 || row >= @grid.length || col < 0 || col >= @grid.first.length
  end

  def can_move?(char, row, col)
    #puts "trying to move : #{char}"
    next_row, next_col = move(char, row, col)
    #puts "next row: #{next_row} - next col: #{next_col}"
    #puts "@grid.first.length :#{@grid.first.length}"
    #puts "@grid.length :#{@grid.length}"
    #puts "next space: #{@grid[next_row][next_col]}"
    out_of_bounds = out_of_bounds?(next_row, next_col)

    #puts "out of bounds: #{out_of_bounds}"
    return false if out_of_bounds

    blocked = @grid[next_row][next_col] == '#'

    #puts "blocked: #{blocked}"
    return false if blocked

    return true if @grid[next_row][next_col] == '.'

    can_shift_boxes?(char, next_row, next_col).tap do |bool|
      #puts "can shift boxes? #{bool}"
    end
  end

  def can_shift_boxes?(char, row, col)
    if char == '^'
      !adjacent_moveable_boxes_up(row, col).empty?
    elsif char == 'v'
      !adjacent_moveable_boxes_down(row, col).empty?
    else
      until !['[', ']'].include?(@grid[row][col])
        row, col = move(char, row, col)
      end

      @grid[row][col] == '.'
    end
  end

  def move(char, row, col)
    case char
    when '^'
      [row - 1, col]
    when '<'
      [row, col - 1]
    when '>'
      [row, col + 1]
    when 'v'
      [row + 1, col]
    end
  end

  def cost
    total = 0
    @grid.each_with_index do |row, row_index|
      row.each_with_index do |col, col_index|
        total += (100 * row_index) + col_index if col == '['
      end
    end

    total
  end

  def print_grid
    system('cls')
    local_grid = Marshal.load(Marshal.dump(@grid))

    puts local_grid.map { |c| c.join }
  end
end

file = File.new('./input.txt')
puts Solution.new(file: file).run
