class Solution
  REGEX = /mul\((?<first>\d{1,3}),(?<second>\d{1,3})\)/
  ALLOWABLE_REGEX = /mul\((?<first>\d{1,3}),(?<second>\d{1,3})\)|(?<allowed>do\(\))|(?<not_allowed>don\'t\(\))/

  def initialize(file:)
    @lines = file
  end

  def run
    multiply = true
    @lines.each.inject(0) do |acc, line|
      acc + line.scan(ALLOWABLE_REGEX).each.inject(0) do |acc, (x, y, enabled, disabled)|
        if x && y && multiply
          acc + (x.to_i * y.to_i)
        else
          multiply = true if !enabled.nil?
          multiply = false if !disabled.nil?

          acc + 0
        end
      end
    end
  end
end

file = File.open('./input.txt')

puts Solution.new(file: file).run
