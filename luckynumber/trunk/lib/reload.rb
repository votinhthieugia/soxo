require 'rubygems'
require 'uri'
require 'time'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :database => 'luckynumber_dev',
  :username => 'root',
  :password => '',
  :host => '127.0.0.1')

class Result < ActiveRecord::Base
end

class Reload
  def self.run
    url = "http://ec2-184-72-166-93.compute-1.amazonaws.com:3000/result/"
    #today = Time.now - 24 * 60 * 60
    today = Time.parse("27-7-2011")
    250.times { |i|
      today = today - 24 * 60 * 60
      date = "#{today.day}-#{today.month}-#{today.year}"
      puts date
      data = `curl #{url}#{date}`
      arr = data.split(",")
      Result.create!(:date => arr.first, :numbers => arr.last)
      sleep 2.0
    }
  end
end

Reload.run
