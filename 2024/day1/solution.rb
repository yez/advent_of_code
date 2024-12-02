class Solution
  def initialize(lines:)
    @first = []
    @second_counts = Hash.new(0)

    lines.each do |line|
      a, b = line.split("\s")
      @first << a.to_i
      @second_counts[b.to_i] += 1
    end
  end

  def run
    @first.each.inject(0) do |acc, elem|
      acc + (elem * @second_counts[elem])
    end
  end
end

['./test_input.txt', './input.txt'].each do |filename|
  next unless File.exist?(filename)
  lines = File.new(filename).readlines
  puts "#{filename}:  #{Solution.new(lines: lines).run}"
end
