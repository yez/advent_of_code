class Solution
  def initialize(file:)
    @grid = []
    @sattelites = {}
    file.readlines.each_with_index do |line, row|
      col_array = []
      line.chomp.split('').each_with_index do |char, col|
        col_array << char
        next if char == '.'
        @sattelites[char] ||= []
        @sattelites[char] << [row, col]
      end
      @grid << col_array
    end
  end

  def run
    amps = Set.new
    @sattelites.each do |letter, coords|

      coords.each do |i_coord|
        coords.each do |j_coord|
          next if i_coord == j_coord

          i_row, i_col = i_coord
          j_row, j_col = j_coord

          row_diff = (i_row - j_row)

          slope = (j_col - i_col).to_f / (j_row - i_row)

          new_row = i_row
          multiplier = 1
          while new_row >= 0 && new_row < @grid.first.length
            #col2 = (row2 - row1) * slope + col1
            new_row = (i_row - (row_diff * multiplier)).tap {|x| x * -1 if slope.negative? }
            new_col = ((new_row - i_row) * slope + i_col).floor
            amp = [new_row, new_col]

            if amp[0] >= 0 &&
                amp[0] < @grid.first.length &&
                amp[1] >= 0 &&
                amp[1] < @grid.length
              amps << [amp[0], amp[1]]

              @grid[amp[0]][amp[1]] = '#' if  ['.', '#'].include?(@grid[amp[0]][amp[1]])
            end
            multiplier += 1
          end
        end
      end
    end

    puts @grid.map {|x| x.join}
    amps.length
  end
end

file = File.new('./input.txt')
puts Solution.new(file: file).run

