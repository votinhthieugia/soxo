require 'rubygems'
require 'net/http'
require 'uri'
require 'nokogiri'

class Loader
  #def self.load_from_24(date)
  #  result = ''
  #  begin
  #    url = "http://ketquaxoso.24h.com.vn/ngay-#{date}.html"
  #    data = `curl #{url}`
  #    puts data
  #    start_index = data.index("Giải đặc biệt")
  #    data = data[start_index, data.length]
  #    end_index = data.index("table")
  #    data = data[0, end_index]
  #    data = "<table><tr><td>" + data
  #    data += "table>"
  #    doc = Nokogiri::HTML(data)
  #    doc.xpath('//td[@class = "number_kq"]').each do |node|
  #      result << node.text.delete("\r").delete("\n").delete("-").delete(" ")
  #    end
  #  rescue Exception => exception
  #    RAILS_DEFAULT_LOGGER.info("exception:" + exception)
  #  end

  #  result
  #end

  def self.load_from_kq(date)
    result = ''
    begin
      url = URI.parse("http://ketqua.net/")
      headers = {}
      headers["Host"] = "ketqua.net"
      headers["User-Agent"] = " Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13"
      res = Net::HTTP.start(url.host, url.port) { |http|
        #http.get("/xo-so/mien-bac/xo-so-truyen-thong.php?ngay=#{date}", headers)
        http.get("/xo-so-truyen-thong.php?ngay=#{date}", headers)
      }
      data = res.body
      start_index = data.index("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" class=\"bot\"")
      end_index = data.index("</table", start_index)
      data = data[start_index, end_index - start_index] + "</table>"
      puts data
      doc = Nokogiri::HTML(data)
      doc.xpath('//td[@class = "bol f2" or @class = "bor f2" or @class = "bor f2 db"]').each do |node|
        result << node.text.delete("\n").delete("\r").delete("\t").delete(" ") unless node.text.strip.eql?("")
      end
    rescue Exception => exception
      RAILS_DEFAULT_LOGGER.info("exception:" + exception)
    end

    puts result
    puts result.length
    result
  end

  def self.load(date_format1, date_format2)
    data = load_from_24(date_format1)
    data = load_from_kq(date_format2) if data.empty? || data.length != 107

    unless data.empty? || data.length != 107
      result = Result.new(:date => date_format1, :numbers => data)
      result.save
    end
  end
end
Loader.load_from_kq("11/10/2012")
