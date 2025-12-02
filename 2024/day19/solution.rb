class Solution
  def initialize(file:)
    @patterns = []
    @cache = {}
    file.readlines.each do |line|
      chomped = line.chomp
      if @towels.nil?
        @towels = chomped.split(',').map(&:strip)
        next
      end

      next if chomped.empty?

      @patterns << chomped
    end
  end

  def run
    @patterns.map do |pattern|
      build_pattern(pattern)
    end.sum
  end

  def possible?(pattern)
    pattern =~ /^#{Regexp.union(*@towels)}+$/
  end

  def build_pattern(string)
    if @cache.key?(string)
      @cache[string]
    elsif string == ''
      1
    else
      @cache[string] = @towels.select { |towel| string.start_with?(towel) }.map { |towel| build_pattern(string[towel.size..-1]) }.sum
    end
  end
end

file = File.open('./input.txt')
puts Solution.new(file: file).run
