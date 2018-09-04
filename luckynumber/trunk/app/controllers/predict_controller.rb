class PredictController < ApplicationController
  before_filter :check_secret_key

  def index
    date = params[:date] || current_date
    date2 = nil
    begin
      d = Time.parse(date)
      date = format_date(d)
      date2 = format_date2(d)
    rescue
      render :text => '' and return
    end

    result = Result.find(:first, :conditions => "date='#{date}'")
    if result.nil?
      Loader.load(date, date2)
      result = Result.find(:first, :conditions => "date='#{date}'")
      if result.nil?
        render :text => ''
      else
        render :text => "#{date},#{result.numbers}"
      end
    else
      render :text => "#{date},#{result.numbers}"
    end
  end

  def results
    from_date = params[:from_date] || current_date
    begin
      d = Time.parse(from_date)
      from_date = format_date(d)
    rescue
      render :text => '' and return
    end

    now = Time.now
    i = 0
    while true
      now2 = now - i.day
      date = format_date(now2)
      log(date)
      break if date.eql?(from_date) || i > 30
      i = i + 1
    end
    now = now2

    num_days = (params[:num_days] || 10).to_i
    if num_days < 1
      render :text => ''
      return
    end

    sql = "select count(*) as n from results where date in ('"
    num_days.times { |i|
      now2 = now - i.day
      sql << format_date(now2) + "','"
    }
    sql << "')"
    sql.gsub!(",''", "")
    numNotExist = Result.count_by_sql(sql)
    num_days += num_days - numNotExist

    valid = true
    results = []
    num_days.times { |i|
      now2 = now - i.day
      date = format_date(now2)
      result = Result.find(:first, :conditions => "date='#{date}'")
      unless result.nil?
        results << date
        results << result.numbers
      end
    }

    unless valid
      render :text => ''
    else
      render :text => results.join(',')
    end
  end

  def bridge
    date = (params[:for_date] || current_date)
    num_days = (params[:num_days] || 4).to_i
    straight = (params[:straight] || 1).to_i == 1
    render :text => "#{date}:#{num_days}:#{straight}:#{Processor.find_bridge(date, num_days, straight)}"
  end

  def special_bridge
    date = (params[:for_date] || current_date)
    render :text => "#{date}:#{Processor.find_special_bridge(date)}"
  end

  def special
    date = (params[:for_date] || current_date)
    num_days = (params[:num_days] || 2).to_i
    straight = (params[:straight] || 1).to_i == 1
    render :text => "#{date}:#{num_days}:#{straight}:#{Processor.find_special(date, num_days, straight)}"
  end

  def statistic
    render :text => Processor.find_statistic
  end

  def follow_bridge_stat
    render :text => Processor.find_bridge_stat
  end

  private
  def current_date
    now = Time.now
    "#{now.day}-#{now.month}-#{now.year}"
  end

  def format_date(time)
    "#{time.day}-#{time.month}-#{time.year}"
  end

  def format_date2(time)
    "#{time.year}/#{time.month}/#{time.day}"
  end

  def check_secret_key
    render :text => '' if false
  end
end
