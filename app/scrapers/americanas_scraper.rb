require 'uri'
require 'nokogiri'
require 'mechanize'
require 'json'

require_relative 'crawler'
require_relative 'db_handler'

class AmericanasScraper
  # Access-Control-Allow-Headers, x-requested-with, x-requested-by
  def initialize
    @link = "https://www.americanas.com.br/categoria/suplementos-e-vitaminas"
    @crawler = Crawler.new
  end

  def start_scraper
    doc = @crawler.get_page(@link)
    target_script = get_script(doc)
    parsed_json = parse_script(target_script)
    categories = doc.search('#collapse-categorias .filter-list-item a')
    categories.each do |category|
      crawl_pages(category["href"])
    end
  end
  
  private
  
  def crawl_pages(category_link)
    doc = @crawler.get_page(@link)
    target_script = get_script(doc)
    parsed_json = parse_script(target_script)
    products = parsed_json["products"]["refs"]
    save_products(products)
  end

  def scrape_page(page)
  end
  
  def get_script(doc)
    scripts = doc.search('script')
    target_script = scripts.select do |script|
      script.text.match(/window.__PRELOADED_STATE__ = /)
    end
  end

  def parse_script(target_script)
    json_string = URI.decode(target_script.first.text)
    json_string.gsub!(/window.__PRELOADED_STATE__ = "/, "")
    parsed_json = JSON.parse(json_string[0..-3])
  end

  def save_products(products_infos)
    pds = []
    products_infos.each do |product_info|
      unless product_info[1]['offerQuantity'].nil?
        collected_product = serialize_product(product_info)
        pds << collected_product
      end
      # DbHandler.save_product(collected_product)
    end
    binding.pry
  end

  def serialize_product(product_info)
    binding.pry
    product = {}
    product[:store_code] = "ame-#{product_info[0]}"
    product[:price] = product_info[1]["offers"]&.first["paymentOptions"]["CARTAO_VISA"]["installments"]&.first["value"]  * 100
    # product[:cashback] = product_info[1]["offers"]&.first["paymentOptions"]["CARTAO_VISA"]["installments"]&.first["cashback"]["value"]
    product[:link] = "https://ad.zanox.com/ppc/?37530276C20702613&ULP=[[https://www.americanas.com.br/produto/#{product_info[0]}]]"
    product[:photo] = product_info[1]['images']&.first['medium']
    product[:name] = product_info[1]['name']
    product[:seller] = I18n.transliterate(
      product_info[1]["offers"]&.first["_embedded"]["seller"]["name"]
    )
    product[:store_id] = 5
    product
  end
end
