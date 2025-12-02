class Solution
  def initialize(file:)
    @keypad = [
      [7, 8, 9],
      [4, 5, 6],
      [1, 2, 3],
      [nil, 0, 'A']
    ]
    keypad_starting_position = [3,2]

    @robot_control = [
      [nil, '^', 'A'],
      ['<', 'v', '>'],
    ]
    robot_control_starting_position = [0,2]

    # robot manipulating keypad
    @robot_one_position =  keypad_starting_position
    # robot manipulating directional pad
    @robot_two_position = robot_control_starting_position
    # robot manipulating directional pad
    @robot_three_position = robot_control_starting_position
    # human manipulating directional pad
    @main_control_position = robot_control_starting_position
  end

  def run
  en

  # bfs for shortest path to next number
  #   bfs for shortest path per move
  #      bfs for shortest path per move
  #        bfs for shortest path per move
  # concat?
end

file = File.new('./test_input.txt')
puts Solution.new(file: file).run

=begin
+---+---+---+
| 7 | 8 | 9 |
+---+---+---+
| 4 | 5 | 6 |
+---+---+---+
| 1 | 2 | 3 |
+---+---+---+
    | 0 | A |
    +---+---+
--------------
    +---+---+
    | ^ | A |
+---+---+---+
| < | v | > |
+---+---+---+
=end
