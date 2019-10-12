require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'pry'

def scrapy
    user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    url = "https://www.musculosnaweb.com.br/suplementos"
    while true
      agent = Mechanize.new
      agent.user_agent = user_agent
      begin
        doc = agent.get(url)
      rescue => e
        puts "error.. retrying after a min"
        sleep 60
        retry
      end
      puts "Scrapping #{url}"
      # define the next index product page to be scraped
      url = "https:#{doc.search('.i-next').first['href']}"
      
      doc.search('.item').each do |product|
        sup = {}
        unless product.blank?
          unless product['parent-sku'].nil?
            sup[:store_code] = "mw-" + product.search('.regular-price').first.attributes['id'].value.gsub(/\D/, '')
          end
          unless product.search('.product-image').nil?
            sup[:link] = product.search('.product-image').first['href']
            sup[:name] = product.search('.product-image').first['title']
            sup[:photo_url] = product.search('.product-image').first.children[1]['src']
          end
          sup[:price] = product.search('.price').first.text.to_i
          sup = prod_scraper(sup)
          if Suplemento.where(store_code: sup[:sku]).empty?
            save(sup)
          else
            update(sup, sup[:sku])
          end
        end
      end
      if !doc.search('.pagination a').search('.next').nil?
        url = "https:#{doc.search('.pagination').search('.next').first['href']}"
      else
        break
      end
    end
  end

scrapy()