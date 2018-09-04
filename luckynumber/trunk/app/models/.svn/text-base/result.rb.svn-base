class Result < ActiveRecord::Base
  HEAD_INDEXES = [3, 8, 13, 18, 23, 28, 33, 38, 43, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 91, 94, 97, 99, 101, 103, 105];
  TAIL_INDEXES = [4, 9, 14, 19, 24, 29, 34, 39, 44, 49, 53, 57, 61, 65, 69, 73, 77, 81, 85, 89, 92, 95, 98, 100, 102, 104, 106];

  def short_numbers
    snumbers = []
    HEAD_INDEXES.length.times { |i| 
      snumbers << "#{numbers[HEAD_INDEXES[i], 1]}#{numbers[TAIL_INDEXES[i], 1]}".to_i
    }
    snumbers.sort
  end

  def immediate_bridges
    puts numbers
    bridge_6_8 = "#{numbers[95, 1]}#{numbers[97, 1]}".to_i
    sum_bridges = []
    i = 50
    while i < 90
      sum_bridges << numbers[i, 2].to_i if numbers[i, 1].to_i + numbers[i + 1, 1].to_i == numbers[i + 2, 1].to_i + numbers[i + 3, 1].to_i
      i += 4
    end

    clamp_bridges = []
    i = 50
    while i < 90
      clamp_bridges << numbers[i + 1, 2].to_i if numbers[i, 1].to_i == numbers[i + 3, 1].to_i
      i += 4
    end

    pos_bridges = []
    ar = Array.new(10)
    10.times { |i| ar[i] = [] }
    i = 0
    while i < 50
      3.times { |j|
        if numbers[i + j, 1].to_i == numbers[i + j + 2, 1].to_i
          ar[numbers[i + j, 1].to_i] << numbers[i + j + 1, 1].to_i 
        end
      }
      i += 5
    end
    while i < 90
      2.times { |j|
        if numbers[i + j, 1].to_i == numbers[i + j + 2, 1].to_i
          ar[numbers[i + j, 1].to_i] << numbers[i + j + 1, 1].to_i 
        end
      }
      i += 4
    end
    while i < 100
      if numbers[i, 1].to_i == numbers[i + 2, 1].to_i
        ar[numbers[i, 1].to_i] << numbers[i + 1, 1].to_i 
      end
      i += 3
    end
    ar.each { |a|
      if a.length > 1
        combinations = a.combination(2).to_a
        combinations.each { |c| pos_bridges << c.join("").to_i }
      end
    }
    [bridge_6_8, sum_bridges.join(','), clamp_bridges.join(','), pos_bridges.join(',')].join("|")
  end
end
