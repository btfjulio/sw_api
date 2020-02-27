require 'nokogiri'
require_relative 'crawler'
require 'mechanize'

class CentauroScraper
  # Access-Control-Allow-Headers, x-requested-with, x-requested-by

  @@page = 1
  @@api_endpoint = "https://api.linximpulse.com/engage/search/v3/navigates?apiKey=centauro-v5&page=#{@@page}&sortBy=relevance&resultsPerPage=40&fields=esportes:suplementos&allowRedirect=true&source=desktop&url=https://esportes.centauro.com.br/nav/esportes/suplementos&showOnlyAvailable=true"

  @@headers = {
    'authority': 'api.linximpulse.com',
    "accept": "application/json, text/plain, */*",
    "accept-language": "en-US,en;q=0.9,la;q=0.8",
    "if-none-match": "W/\"1139f4-b8fj9ZFB9eBFI70WeGAqfge06fk\"",
    "sec-fetch-dest": "empty",
    "sec-fetch-mode": "cors",
    "sec-fetch-site": "cross-site",
    "referer": "https://esportes.centauro.com.br/nav/esportes/suplementos/0",
    "origin": "https://esportes.centauro.com.br"
  }

  def access_api
    agent = create_crawler
    products = get_api_info(agent)
  end

  def create_crawler
    agent = Mechanize.new
    agent.request_headers = @@headers
    agent.user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    agent
  end

  def get_api_info(agent)
    info = make_request(agent)
    last_page = get_last_page(info)
    products = []
    while @@page <= last_page
      info = make_request(agent)
      info['products'].each do |product|
        DBHandler.serialize_product(product)
      end
      sleep 3
      @@page += 1
      puts products
    end
  end

  def make_request(agent)
    response = agent.get(@@api_endpoint)
    JSON.parse(response.body)
  rescue StandardError => e
    puts e
    puts "error.. retrying after a min"
  end

  def get_last_page(info)
    info['pagination']['last'].match(/page=([0-9\.]+)/)[1].to_i
  end

  def serialize_product(info)
    product = {}
    product[:price] = info['price'] * 100
    product[:link] = "https://ad.zanox.com/ppc/?37530276C20702613&ULP=[[#{info['url']}]]"
    product[:photo] = "https:#{info['images']['default']}"
    product[:name] = info['details']['Descricao_Resumida']&.first
    product[:store_code] = info['details']['sku_list']&.first
    product[:category] = info['details']['CategoriaA2']&.first
    product[:brand] = info['details']['Marca']&.first
    product[:seller] = I18n.transliterate(info['details']['NomeSeller']&.first)
    product[:stock] = info['details']['Estoque']&.first
    product[:promo] = info['details']['Promoção']&.first
    product
  end

end
