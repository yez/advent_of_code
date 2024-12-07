class Solution
  def initialize(file:)
    @equations = {}
    file.readlines.each do |line|
      result, numbers = line.chomp.split(':')
      @equations[result.to_i] = numbers.split(' ').map(&:to_i)
    end
  end

  def run
    winners = Set.new
    @equations.each do |result, numbers|
      ['+','*', '||'].repeated_permutation(numbers.length - 1).each do |perm|
        expr = numbers.zip(perm).flatten.compact
        while expr.length >= 3
          first_operand = expr.shift
          operator = expr.shift
          second_operand = expr.shift
          if operator == '||'
            expr.unshift("#{first_operand}#{second_operand}".to_i)
          else
            expr.unshift(first_operand.send(operator.to_sym, second_operand))
          end
        end

        if expr[0] == result
          winners << result
          break
        end
      end
    end

    winners.inject(:+)
  end
end

file = File.open('./input.txt')
puts Solution.new(file: file).run
