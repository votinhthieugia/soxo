class Bridge
  attr_accessor :days

  def initialize(data)
    @days = []
    num_days = data.length
    num_days.times { |i|
      day = Day.new(data[i])
      @days << day
    }
  end

  def find_bridge(num_days, straight)
    results = []
    return results if num_days > @days.length
    start_day_index = @days.length - num_days
    start_day = @days[start_day_index]
    Day::NUM_DIGITS.times { |i|
      for j in (i + 1)..(Day::NUM_DIGITS - 1)
        couple = start_day.number_at(i) * 10 + start_day.number_at(j)
        is_bridge = true
        day_index = start_day_index + 1

        while day_index < @days.length
          next_day = @days[day_index];
          exist = straight ? next_day.is_straight_bridge(couple) : 
                             (next_day.is_straight_bridge(couple) || next_day.is_reversed_bridge(couple))

          if exist
            couple = next_day.number_at(i) * 10 + next_day.number_at(j)
          else
            is_bridge = false
            break
          end

          day_index += 1
        end

        #results << "#{couple}-#{i}-#{j}" if is_bridge
        results << [couple, i, j] if is_bridge
      end
    }

    results.sort!
    results = results.collect { |r| r.join("-") }
    results.join(",")
  end

  def find_special(num_days, straight)
    results = []
    return results if num_days > @days.length
    start_day_index = @days.length - num_days
    start_day = @days[start_day_index]
    Day::NUM_DIGITS.times { |i|
      for j in (i + 1)..(Day::NUM_DIGITS - 1)
        couple = start_day.number_at(i) * 10 + start_day.number_at(j)
        is_bridge = true
        day_index = start_day_index + 1

        while day_index < @days.length
          next_day = @days[day_index];
          exist = straight ? next_day.is_straight_special(couple) : 
                             (next_day.is_straight_special(couple) || next_day.is_reversed_special(couple))

          if exist
            couple = start_day.number_at(i) * 10 + start_day.number_at(j)
          else
            is_bridge = false
            break
          end

          day_index += 1
        end

        #results << "#{couple} (#{i}-#{j})" if is_bridge
        results << [couple, i, j] if is_bridge
      end
    }

    results.sort!
    results = results.collect { |r| r.join("-") }
    results.join(",")
  end

  def find_details(num_days, pos1, pos2)
  end
end
