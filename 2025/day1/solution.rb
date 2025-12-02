class Solution
  def initialize(lines:)
    @starting_point = 50

    @counter = 0
    @lines = lines
  end

  def run
    position = @starting_point

    @lines.each do |line|
      direction = line[0].chomp
      turns = line[1..-1].to_i

      new_unbound_position = if direction == 'L'
         (position - turns)
      else
         (position + turns)
      end

      new_position = new_unbound_position % 100
      @counter += 1 if new_position.zero?

      crosses = (new_unbound_position.abs / 100)
      crosses -= 1 if new_position.zero? && crosses > 0
      crosses += 1 if new_unbound_position < 0 && !position.zero?
      @counter += crosses

      position = new_position
    end

    @counter
  end
end

[
  './test_input.txt',
  './input.txt'
].each do |filename|
  next unless File.exist?(filename)
  lines = File.new(filename).readlines
  puts "#{filename}:  #{Solution.new(lines: lines).run}"
end
