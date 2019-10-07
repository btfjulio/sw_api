require 'nokogiri'
require 'open-uri'
require 'pry' 
require 'csv'
require 'mechanize'

# scrape to index product page
def scrapy
  user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
  url = "https://www.netshoes.com.br/suplementos"
  while true
    agent = Mechanize.new
    agent.user_agent = user_agent
    begin
      doc = agent.get(url)
    rescue => e
      puts "error.. retrying"
      sleep 600
      binding.pry
      retry
    end
    puts "Scrapping #{url}"
    url = "https:#{doc.search('.pagination a').first['href']}"
    doc.search('.item-card').each do |product|
      sup = {}
      unless product.blank?
        unless product['parent-sku'].nil?
          sup[:sku] = product['parent-sku']
        end
        unless product.search('.item-card__description__product-name').first['href'].nil?
          sup[:link] = "https:#{product.search('.item-card__description__product-name').first['href']}"
        end
        unless product.search('.item-card__description__product-name').first.nil?
          sup[:name] = product.search('.item-card__description__product-name').text
        end
        sup = prod_scraper(sup)
        write_csv(sup)
      end
    end
    if !doc.search('.pagination a').search('.next').nil?
      url = "https:#{doc.search('.pagination').search('.next').first['href']}"
    else
      break
    end
  end
end

# scrape to sho product page
def prod_scraper(sup)
  sleep 1
  agent = Mechanize.new
  begin
    doc = agent.get(sup[:link])
  rescue => e
    puts "error.. retrying"
    sleep 600
    binding.pry
    retry
  end
  puts "Scrapping #{sup[:name]}"
  unless doc.search('.default-price').first.nil?
    sup[:price] = doc.search('.default-price').first.text
  end
  unless doc.search('.product-seller-name').first.nil?
    sup[:seller] = doc.search('.product-seller-name').first.text
  end
  unless doc.search('.dlvr').first.nil?
    sup[:sender] = doc.search('.dlvr').first.text
  end
  unless doc.search('.sku-select').search('.content').first.nil?
    sup[:flavor] = doc.search('.sku-select').search('.item a').first.text
  end
  sup
end

def write_csv(sup)
  CSV.open('netshoes_products.csv', 'a+') do |csv|
    csv << [sup[:sku], sup[:link], sup[:name], sup[:price], sup[:sender], sup[:seller], sup[:flavor]]
  end
end

scrapy()
