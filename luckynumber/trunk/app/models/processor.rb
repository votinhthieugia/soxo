class Processor
  def self.find_bridge(for_date, num_days, straight)
    now = Time.now
    i = -1
    while true
      now2 = now - i.day
      date = format_date(now2)
      if date.eql?(for_date) 
        now = now2 - 1.day
        break 
      elsif i > 10
        return []
      end
      i = i + 1
    end

    num_days = 4 if num_days < 4
    data = []
    dates = []
    i = 0
    while data.length < num_days && i < 30
      date = format_date(now - i.day)
      result = Result.find(:first, :conditions => ["date=?", date])
      unless result.nil?
        data << result.numbers 
        dates << date
      else
        return []
      end
      i = i + 1
    end
    return [] if data.length < num_days
    infor = []
    data.each_with_index { |day, index|
      infor << [dates[index], day].join("=>")
    }
    bridge = Bridge.new(data.reverse)
    [infor.join("|"), bridge.find_bridge(num_days, straight)].join(":")
  end

  def self.find_special_bridge(for_date)
    now = Time.now
    i = -1
    while true
      now2 = now - i.day
      date = format_date(now2)
      if date.eql?(for_date) 
        now = now2 - 1.day
        break 
      elsif i > 30
        return ''
      end
      i = i + 1
    end

    result = Result.find(:first, :conditions => ["date=?", format_date(now)])
    if result
      return result.immediate_bridges
    else
      return ''
    end
  end

  def self.find_special(for_date, num_days, straight)
    now = Time.now
    i = 0
    while true
      now = now - i.day
      date = format_date(now)
      if date.eql?(for_date) 
        now = now - 1.day
        break 
      elsif i > 10
        return []
      end
      i = i + 1
    end

    num_days = 2 if num_days < 2
    data = []
    dates = []
    i = 0
    while data.length < num_days && i < 30
      date = format_date(now - i.day)
      result = Result.find(:first, :conditions => ["date=?", date])
      unless result.nil?
        data << result.numbers 
        dates << date
      end
      i = i + 1
    end
    return [] if data.length < num_days
    infor = []
    data.each_with_index { |day, index|
      infor << [dates[index], day].join("=>")
    }
    bridge = Bridge.new(data.reverse)
    [infor.join("|"), bridge.find_special(num_days, straight)].join(":")
  end

  def self.find_statistic
    now = Time.now.gmtime
    now = now - 1.day if now.hour < 13
    for_date = format_date(now)
    results = []
    40.times { |i|
      date = format_date(now - i.day)
      result = Result.find(:first, :conditions => ["date=?", date])
      results << result unless result.nil?
    }
    min_max_40_stat = min_max_40(results)
    hungry10 = hungry_10(results)
    drop_data = drop(results)
    [for_date, min_max_40_stat.join("-"), hungry10.join("-"), drop_data.join("-")].join("|")
  end

  def self.find_bridge_stat
  end

  private

  def self.format_date(time)
    "#{time.day}-#{time.month}-#{time.year}"
  end

  def self.min_max_40(results)
    numbers = Array.new(100, 0)
    results.each { |result|
      snumbers = result.short_numbers
      snumbers.each { |n|
        numbers[n] += 1
      }
    }
    posibilities = {}
    numbers.each_with_index { |n, index| posibilities["#{index}"] = n }
    posibilities.sort { |a,b| a[1] <=> b[1] }
  end

  def self.drop(results)
    drop_data = {}
    snumbers = results.first.short_numbers
    copied_results = Array.new(results[1, results.length - 1])
    snumbers.each { |n|
      i = 0
      while i < copied_results.length && copied_results[i].short_numbers.include?(n)
        i += 1
      end
      drop_data["#{n}"] = i + 1 if i > 0 
    }
    drop_data.sort { |a,b| a[1] <=> b[1] }
  end

  def self.hungry_10(results)
    numbers = []
    results.each { |result|
      numbers.concat(result.short_numbers)
    }
    misses = {}
    100.times { |i|
      index = numbers.index(i) 
      if index && index > 270
        misses["#{i}"] = index / 27
      end
    }
    misses.sort { |a,b| a[1] <=> b[1] }
  end
end
