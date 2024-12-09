class Solution
  def initialize(file:)
    @visual = []
    @mapping = []
    # { priority: , visual_start_index:, length:, char: }

    file.readlines.each do |line|
      file_id_counter = 0
      line.chomp.chars.each_with_index do |char, index|
        file_length = char.to_i
        if index % 2 == 0
          @mapping << { priority: index, visual_start_index: @visual.length, length: file_length, char: file_id_counter }
          file_length.times do
            @visual << file_id_counter
          end
          file_id_counter += 1
        else
          file_length.times do
            @visual <<  '.'
          end
        end
      end
    end

    @mapping.sort_by! {|x| -x[:priority] }
  end

  def run
    @mapping.each do |file_hash|
      find_space_and_replace(file_hash)
    end

    checksum
  end

  def find_space_and_replace(file_hash)
    i = 0
    while i < @visual.length
      space = 0
      char = @visual[i]
      if i >= file_hash[:visual_start_index]
        return
      end

      if char == '.'
        if @visual.slice(i,file_hash[:length]).all? {|c| c == '.' }
          # replace in space
          @visual.fill(file_hash[:char], (i..i + file_hash[:length] - 1))
          # replace old spot

          existing_end = file_hash[:visual_start_index] + file_hash[:length] - 1
          @visual.fill('.', (file_hash[:visual_start_index]..existing_end))
          return
        else
          i += 1
        end
      else
        i += 1
      end
    end
  end

  def find_file(space, visual_index)
    found = @mapping.find do |mapping|
      mapping[:length] <= space && mapping[:visual_start_index] > visual_index
    end

    if found
      @mapping.delete_at(@mapping.index(found))
    end

    found
  end

  def checksum
    @visual.each_with_index.inject(0) do |acc, (file_id, index)|
      result = file_id == '.' ? 0 : file_id * index
      acc + result
    end
  end
end

file = File.new('./input.txt')

puts Solution.new(file: file).run
