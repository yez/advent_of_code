class Solution
  def initialize(file:)
    @lines = file.readlines.map { |line| line.split(' ').map(&:to_i) }
  end

  def run
    safe, unsafe = @lines.partition do |line|
      result = safe_report?(report: line)
      if !result
        (0..line.length - 1).each do |index|
          cloned = line.clone
          cloned.delete_at(index)
          result = safe_report?(report: cloned)
          break if result
        end
      end
      result
    end

    safe.length
  end

  def safe_report?(report:)
    difference = nil
    safe = true
    report.each_with_index do |level, index|
      break if index == report.length - 1
      next_level = report[index + 1]
      if level > next_level && [1, 2, 3].include?(level - next_level) && [nil, -1].include?(difference)
        difference = -1
      elsif level < next_level && [1, 2, 3].include?(next_level - level) && [nil, 1].include?(difference)
        difference = 1
      else
        safe = false
        break
      end
    end
    safe
  end
end

file = File.open('./input.txt')
puts Solution.new(file: file).run
