class Solution
  REGEX = /(?<which>A|B|Prize):\s+X[^\d]+(?<x>\d+),\s+Y[^\d]+(?<y>\d+)/
  #CONVERSION_ADD = 10000000000000
  CONVERSION_ADD = 10000000000000

  def initialize(file:)
    @rounds = []
    round = {}
    file.readlines.each do |line|
      chomped = line.chomp
      if chomped.empty?
        @rounds << round
        round = {}
        next
      end

      chomped.scan(REGEX).each do |(letter, x_step, y_step)|
        if letter == 'Prize'
          round[letter] = { x: x_step.to_i + CONVERSION_ADD, y: y_step.to_i + CONVERSION_ADD }
        else
          round[letter] = { x: x_step.to_i, y: y_step.to_i }
        end
      end
    end
    @rounds << round
  end

  def run
    i = 0
    @rounds.each.inject(0) do |acc, round_hash|
      a_press, b_press = algo(round_hash)
      if a_press % 1 == 0 && b_press % 1 == 0
        acc + ((a_press * 3) + (b_press * 1))
      else
        acc + 0
      end
      #i += 1
      #x_combinations = find_combinations([round_hash['A'][:x], round_hash['B'][:x]], round_hash['Prize'][:x])
      #y_combinations = find_combinations([round_hash['A'][:y], round_hash['B'][:y]], round_hash['Prize'][:y])
#
#      common = x_combinations & y_combinations
#      min_cost_for_round = common.map do |a_press, b_press|
#        (a_press * 3) + (b_press * 1)
#      end.min
#
#      if min_cost_for_round
#        puts "solution found for round:#{i}"
#      end

#      acc + (min_cost_for_round.nil? ? 0: min_cost_for_round)
    end
  end

  def algo(round_hash)
    x_1 = round_hash['A'][:x]
    y_1 = round_hash['A'][:y]
    x_2 = round_hash['B'][:x]
    y_2 = round_hash['B'][:y]
    t_1 = round_hash['Prize'][:x]
    t_2 = round_hash['Prize'][:y]

#    26a + 67b = 12748 + 10T
#    66a + 21b = 12176 + 10T
#
#     21 * (26a + 67b) =  21 * (12748 + 10T)
#    -67 * (66a + 21b) = -67 * (12176 + 10T)
#
#      546a + 1407b =  267708 + 210T
#    -4422a - 1407b = -815792 - 670T
#    ================================
#    -3876a +    0b = -548084 - 460T
#
#    -3876a = -460_000_000_548_084
#    -3876a / -3876 = -460_000_000_548_084 / -3876
#    a = 118_679_050_709



#    b=(py*ax-px*ay)/(by*ax-bx*ay) a=(px-b*bx)/ax

    b = ((t_2 * x_1 - t_1 * y_1).to_f / (y_2 * x_1 - x_2 * y_1))
    a = (t_1 - b * x_2) / x_1

    [a, b]
  end

  def find_combinations(numbers, target)
    Set.new.tap do |combos|
      100.downto(0).each do |i|
        100.downto(0).each do |j|
          next if i == 0 && j == 0

          #puts "---------"
          #uts target % ((numbers[0] * i) + (numbers[1] * j))
          #uts target % ((numbers[0] * j) + (numbers[1] * i))
          #uts "---------"

          if target % ((numbers[0] * i) + (numbers[1] * j)) == 0
            combos << [i, j]
          elsif target % ((numbers[0] * j) + (numbers[1] * i)) == 0
            combos << [j, i]
          end
        end
      end
    end
  end
end

file = File.new('./input.txt')

puts Solution.new(file: file).run
