require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'json'
require 'pry'

def scrapy
    user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    url = "https://www.amazon.com.br/s?bbn=16769353011&rh=n%3A16215417011%2Cn%3A%2116215418011%2Cn%3A16769353011"
    while true
        agent = Mechanize.new
        agent.user_agent = user_agent
        doc = agent.get(url)
        puts "Scrapping #{url}"
        suplementos = []
        doc.search('.s-result-item').each do |product|
            sleep 1
            sup_hash = create_hash(product)
            write_json(sup_hash)
        end
        if !doc.search('.a-last a').empty?
           url = "https://www.amazon.com.br#{doc.search('.a-last a').first['href']}"
        elsif doc.search('.s-result-item').length > 4

           break
        else
            puts 'puts nothing returned sleepping for 100 min..'
            sleep 6000
            puts 'trying again'
        end
    end
end

def create_hash(product)
    sup = {}
    unless product.blank?
        unless product['data-asin'].nil?
            sup[:asin] = product['data-asin']
        end
        unless product.search('.a-link-normal').nil?
            sup[:link] = "https://www.amazon.com.br#{product.search('.a-link-normal').first['href']}"
        end
        unless product.search('.a-text-normal').first.nil?
            sup[:name] = product.search('.a-text-normal').first.text.strip
            puts "Scrapping #{sup[:name]}"
        end
        unless product.search('.a-price-whole').first.nil?
            sup[:price] = "#{product.search('.a-price-whole').first.text.strip}#{product.search('.a-price-fraction').first.text}"
        end
    end
    sup
end

def write_json(sup)
    suples = JSON.parse(File.read('db/sup.json'))
    suples['suplementos'] << sup
    File.open('./db/sup.json',"w+") do |f|
        f.write(suples.to_json)
    end
end

File.open('./db/sup.json',"w+") do |f|
    suplementos = {suplementos:[]}
    f.write(JSON.pretty_generate(suplementos))
end
scrapy()
puts 'Everything updated'