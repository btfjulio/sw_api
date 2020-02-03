require_relative 'crawler'
require 'json'

def scrapy
    url = "https://www.amazon.com.br/s?bbn=16769353011&rh=n%3A16215417011%2Cn%3A%2116215418011%2Cn%3A16769353011"
    crawler = Crawler.new()
    create_json()
    while true
        doc = crawler.get_page(url)
        puts "Scrapping #{url}"
        suplementos = []
        crawler.get_products(doc, '.s-result-item').each do |product|
            sup = prod_scraper(crawler, product)
            write_json(sup)
        end
        next_page = crawler.get_content('.a-last a', doc, { attrib: 'href' })
        url = "https://www.amazon.com.br#{next_page}"
        break if !next_page
        sleep rand(1..5)
    end
end

def prod_scraper(crawler, product)
    sup = {}
    unless product.blank?
        sup[:asin] = crawler.get_attribute(product, 'data-asin')
        link = crawler.get_content('.a-link-normal', product, { attrib: 'href' })
        sup[:link] = "https://www.amazon.com.br#{link}"
        sup[:name] = crawler.get_content('h2', product) { |prod| prod.text.strip() }
        sup[:price] = crawler.get_content('.a-price .a-offscreen', product) { |prod| prod.text.strip() }
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
