class TaskController < ApplicationController
  def index
    render :text => ''
  end

  def load
    now = Time.now
    i = 0
    while i < 30
      today = now - (29 - i).day
      date1 = "#{today.day}-#{today.month}-#{today.year}"
      date2 = "#{today.year}-#{today.month}-#{today.day}"
      result = Result.find(:first, :conditions => "date='#{date1}'")
      Loader.load(date1, date2) if result.nil?
      i = i + 1
    end

    render :nothing => true
  end
end
