require_relative 'crawler'
require 'json'

def scrapy
    url = "https://www.amazon.com.br/s?bbn=16769353011&rh=n%3A16215417011%2Cn%3A%2116215418011%2Cn%3A16769353011"
    crawler = Crawler.new()
    while true
        doc = crawler.get_page(url)
        puts "Scrapping #{url}"
        suplementos = []
        crawler.get_products(doc, '.s-result-item').each do |product|
            sup = prod_scraper(crawler, product)
            write_json(sup)
        end
        next_page = crawler.get_tag_content('.a-last a', doc, { attrib: 'href' })
        url = "https://www.amazon.com.br#{next_page}"
        break if !next_page
        sleep rand(1..3)
    end
end

def prod_scraper(crawler, product)
    sup = {}
    unless product.blank?
        sup[:asin] = crawler.get_attribute(product, 'data-asin')
        link = crawler.get_tag_content('.a-link-normal', product, { attrib: 'href' })
        sup[:link] = "https://www.amazon.com.br#{link}"
        sup[:name] = crawler.get_tag_content('h2', product, { method: 'text' })
        sup[:price] = crawler.get_tag_content('.a-price .a-offscreen', product, { method: 'text' })
        puts "Scrapping #{sup[:name]}"
    end
    sup
end

def write_json(sup)
    suples = JSON.parse(File.read('./app/scrapers/suples.json'))
    suples['suplementos'] << sup
    File.open('./app/scrapers/suples.json',"w+") do |f|
        f.write(suples.to_json)
    end
end

def create_json()
    File.open('./app/scrapers/suples.json',"w+") do |f|
        suplementos = {suplementos:[]}
        f.write(JSON.pretty_generate(suplementos))
    end
end

create_json()
scrapy()
puts 'Everything updated'

