class CrawlsController < ApplicationController
  def self.crawl_all
    tr = []
    tr << Thread.new{self.engineer}
    tr << Thread.new{self.computer}
    tr << Thread.new{self.mysnu}
    tr.each{|t|t.join}
    #@return = 0
  end

  def self.mysnu
    begin
    system("~/phantomjs-1.9.2-linux-x86_64/bin/phantomjs --webdriver=9134 &")
    sleep(1)
    browser = Selenium::WebDriver.for(:remote, :url => "http://localhost:9134")
    #browser = Selenium::WebDriver.for(:firefox)
    browser.get('http://sso.snu.ac.kr/snu/ssologin.jsp')
    browser.find_element(:id,'si_id').send_keys('rapaellk')
    browser.find_element(:id,'si_pwd').send_keys('------')
    browser.find_element(:id,'btn_login').click
    browser.get('http://community.snu.ac.kr/bbs/bbs.message.list.screen?bbs_id=460')
    conv = Iconv.new('ISO-8859-1//IGNORE','UTF-8')
    browser.find_elements(:xpath, '//table[@id="table"]/tbody/tr').each do |tr|
      trarray = tr.find_elements(:tag_name, "td")
      length = trarray.length
      title = conv.iconv(trarray[length-4].text).encode('utf-8','euc-kr',:invalid => :replace, :undef => :replace)
      date = Date.strptime(trarray[length-2].text, "%y/%m/%d")
      link = trarray[length-4].find_element(:css,'a').attribute("href")
      node = link[link.index("&message_id=")+12..link.index("&currentPage")-1]
      newbrowser = Selenium::WebDriver.for(:remote, :url => "http://localhost:9134")
      newbrowser.get(link)
      ct = conv.iconv(newbrowser.find_element(:class, "view_cont").text).encode('utf-8','euc-kr',:invalid => :replace, :undef => :replace)
      if ct.size > 99 then
        ct = ct[0,100]+"..."
      end
      unless Mysnu.exists?(node) then
        Mysnu.create(title: title, date:date, link:link, node:node, content:ct)
      end
    end

    browser.get('http://community.snu.ac.kr/bbs/bbs.message.list.screen?bbs_id=1&currentPage=1&search_field=title&search_word=&classified_value=')
    browser.find_elements(:xpath, '//table[@id="table"]/tbody/tr').each do |tr|
      trarray = tr.find_elements(:tag_name, "td")
      length = trarray.length
      title = conv.iconv(trarray[length-4].text).encode('utf-8','euc-kr',:invalid => :replace, :undef => :replace)
      date = Date.strptime(trarray[length-2].text, "%y/%m/%d")
      link = trarray[length-4].find_element(:css,'a').attribute("href")
      node = link[link.index("&message_id=")+12..link.index("&currentPage")-1]
      newbrowser = Selenium::WebDriver.for(:remote, :url => "http://localhost:9134")
      newbrowser.get(link)
      ct = conv.iconv(newbrowser.find_element(:class, "view_cont").text).encode('utf-8','euc-kr',:invalid => :replace, :undef => :replace)
      if ct.size > 99 then
        ct = ct[0,100]+"..."
      end
      unless Mysnu.exists?(node) then
        Mysnu.create(title: title, date:date, link:link, node:node, content:ct)
      end
    end
    browser.quit
    system("ps -ef | grep phantomjs | awk '{print $2}' | xargs kill -9")
    rescue
      puts "Mysnu Error : #{$!}\n"
      system("ps -ef | grep phantomjs | awk '{print $2}' | xargs kill -9")
    end

  end

  def self.computer
    begin
    ('0'..'2').each do |pgn|
      url = "http://cse.snu.ac.kr/department-notices?&keys=&page="+pgn
      doc = Nokogiri::HTML(open(url))
      doc.xpath('//div[@id="block-system-main"]/div/div/div/table/tbody/tr').each do |tr|
        title = tr.css("td.views-field-title a").text
        date = Date.strptime(tr.css("td.views-field-created").text.strip, "%Y/%m/%d")
        hr=tr.css('td.views-field-title a').first.attr('href')
        link = "http://cse.snu.ac.kr"+hr
        node = hr.delete "/node/"
        contentdoc = Nokogiri::HTML(open(link))
        ct = contentdoc.xpath('//div[@id="block-system-main"]/div/div/div/div[@class="field field-name-body field-type-text-with-summary field-label-hidden"]/div/div').text
        if ct.size > 99 then
          ct = ct[0,100]+"..."
        end
        unless Computer.exists?(node) then
          Computer.create(title: title, date:date, link:link, node:node, content:ct)
        end
      end
    end
    rescue
      puts "Computer error : #{$!}\n"
    end
  end

  def self.engineer
    begin
    ('1'..'2').each do |pgn|
      url = "http://eng.snu.ac.kr/bbs/notice_list.php?bbsid=notice&user_rpp=&code_value=SN060101&stype=&sword=&page="+pgn
      doc = Nokogiri::HTML(open(url))
      doc.xpath('//form[@name="form1"]/div[@class="clear font_gray bold skin_1"]/ol').each do |ol|
        liarray = ol.xpath('./li')
        title = liarray[2].xpath('./a').text
        date = Date.strptime(liarray[6].text.strip, "%Y-%m-%d")
        javalink = liarray[2].xpath('./a').first.attr('href')
        node = javalink[javalink.index("d('")+3 ... javalink.index("')")]
        link = "http://eng.snu.ac.kr/bbs/notice_view.php?code_value=SN060101&bbsid=notice&bbsidx="+node
        ct = liarray[2].xpath('./div').text.strip
        if ct.size > 99 then
          ct = ct[0,100]+"..."
        end
        unless Engineer.exists?(node) then
          Engineer.create(title: title, date:date, link:link, node:node, content:ct)
        end
      end
      doc.xpath('//form[@name="form1"]/div[@class="clear cu_list_1"]/ol').each do |ol|
        liarray = ol.xpath('./li')
        title = liarray[2].xpath('./a').text
        date = Date.strptime(liarray[6].text.strip, "%Y-%m-%d")
        javalink = liarray[2].xpath('./a').first.attr('href')
        node = javalink[javalink.index("d('")+3 ... javalink.index("')")]
        link = "http://eng.snu.ac.kr/bbs/notice_view.php?code_value=SN060101&bbsid=notice&bbsidx="+node
        ct = liarray[2].xpath('./div').text.strip
        if ct.size > 99 then
          ct = ct[0,100]+"..."
        end
        unless Engineer.exists?(node) then
          Engineer.create(title: title, date:date, link:link, node:node, content:ct)
        end
      end
    end
    rescue
      puts "Engineer error : #{$!}\n"
    end
  end

=begin
  def self.dormitory
    begin
    url = "http://cse.snu.ac.kr/department-notices?&keys=&page="+pgn
    doc = Nokogiri::HTML(open(url))
    doc.xpath('//div[@id="block-system-main"]/div/div/div/table/tbody/tr').each do |tr|
      title = tr.css("td.views-field-title a").text
      date = Date.strptime(tr.css("td.views-field-created").text.strip, "%Y/%m/%d")
      hr=tr.css('td.views-field-title a').first.attr('href')
      link = "http://cse.snu.ac.kr"+hr
      node = hr.delete "/node/"
      contentdoc = Nokogiri::HTML(open(link))
      ct = contentdoc.xpath('//div[@id="block-system-main"]/div/div/div/div[@class="field field-name-body field-type-text-with-summary field-label-hidden"]/div/div').text
      if ct.size > 99 then
        ct = ct[0,100]+"..."
      end
      unless Computer.exists?(node) then
        Computer.create(title: title, date:date, link:link, node:node, content:ct)
      end
    end
    rescue
      puts "Computer error : #{$!}\n"
    end
  end

=end

end


