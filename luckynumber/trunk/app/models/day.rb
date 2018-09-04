class Day
  NUM_DIGITS = 107
  NUM_COUPLES = 27

  attr_accessor :numbers, :couples

  def initialize(data)
    @numbers = []
    @couples = []
    data.each_char { |n| @numbers << n.to_i }
    @couples = find_couples
  end

  def number_at(index)
    @numbers[index]
  end

  def special
    @numbers[3] * 10 + @numbers[4]
  end

  def find_couples
    results = []
    NUM_COUPLES.times { |i|
      if i < 10
        results << @numbers[(i + 1) * 5 - 2] * 10 + @numbers[(i + 1) * 5 - 1]
      elsif i < 20
        results << @numbers[50 + (i - 9) * 4 - 2] * 10 + @numbers[50 + (i - 9) * 4 - 1]
      elsif i < 23
        results << @numbers[90 + (i - 19) * 3 - 2] * 10 + @numbers[90 + (i - 19) * 3 - 1]
      else
        results << @numbers[99 + (i - 22) * 2 - 2] * 10 + @numbers[99 + (i - 22) * 2 - 1]
      end
    }
    results
  end

  def is_straight_bridge(couple)
    @couples.each { |c|
      return true if c == couple
    }
    return false
  end

  def is_reversed_bridge(couple)
    @couples.each { |c|
      return true if (((c % 10) == (couple / 10)) && ((c / 10) == (couple % 10)))
    }
    return false
  end

  def is_straight_special(couple)
    return couple == special
  end

  def is_reversed_special(couple)
    return (((@couples[0] % 10) == (couple / 10)) && ((@couples[0] / 10) == (couple % 10)))
  end
end
