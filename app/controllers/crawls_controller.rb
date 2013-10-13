class CrawlsController < ApplicationController
  def self.crawl_all
    self.computer
    self.mysnu
    #@return = 0
  end

  def self.mysnu
    browser = Selenium::WebDriver.for(:remote, :url => "http://localhost:9134")
    browser.get('http://sso.snu.ac.kr/snu/ssologin.jsp?si_redirect_address=http://community.snu.ac.kr/bbs/bbs.message.list.screen?bbs_id=460')
    browser.find_element(:id,'si_id').send_keys('rapaellk')
    browser.find_element(:id,'si_pwd').send_keys('4485287k!')
    browser.find_element(:id,'btn_login').click
    conv = Iconv.new('ISO-8859-1//IGNORE','UTF-8')
    browser.find_elements(:xpath, '//table[@id="table"]/tbody/tr').each do |tr|
      trarray = tr.find_elements(:tag_name, "td")
      length = trarray.length
      title = conv.iconv(trarray[length-4].text).encode('utf-8','euc-kr',:invalid => :replace, :undef => :replace)
      date = Date.strptime(trarray[length-2].text, "%y/%m/%d")
      link = trarray[length-4].find_element(:css,'a').attribute("href")
      node = link[link.index("&message_id=")+12..link.index("&currentPage")-1]
      unless Mysnu.exists?(node) then
        Mysnu.create(title: title, date:date, link:link, node:node)
      end
    end
    browser.quit
  end

  def self.computer
    ('0'..'2').each do |pgn|
      url = "http://cse.snu.ac.kr/department-notices?&keys=&page="+pgn
      doc = Nokogiri::HTML(open(url))
      doc.xpath('//div[@id="block-system-main"]/div/div/div/table/tbody/tr').each do |tr|
        title = tr.css("td.views-field-title a").text
        date = Date.strptime(tr.css("td.views-field-created").text.strip, "%Y/%m/%d")
        hr=tr.css('td.views-field-title a').first.attr('href')
        link = "http://cse.snu.ac.kr"+hr
        node = hr.delete "/node/"
        unless Computer.exists?(node) then
          Computer.create(title: title, date:date, link:link, node:node)
        end
      end
    end
  end
end


