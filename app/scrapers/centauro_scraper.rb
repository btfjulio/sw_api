require 'nokogiri'
require_relative 'crawler'
require_relative 'db_handler'
require 'mechanize'

class CentauroScraper
  # Access-Control-Allow-Headers, x-requested-with, x-requested-by

  @@page = 1
  
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
    get_api_info(agent)
    puts "Centauro infos collected"
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
    while @@page <= last_page
      info = make_request(agent)
      get_products(info)
      sleep 3
      @@page += 1
    end
  end
  
  def make_request(agent)
    api_endpoint = "https://api.linximpulse.com/engage/search/v3/navigates?apiKey=centauro-v5&page=#{@@page}&sortBy=relevance&resultsPerPage=40&fields=esportes:suplementos&allowRedirect=true&source=desktop&url=https://esportes.centauro.com.br/nav/esportes/suplementos&showOnlyAvailable=true"
    response = agent.get(api_endpoint)
    JSON.parse(response.body)
  rescue StandardError => e
    puts e
    puts "error.. retrying after a min"
  end

  def get_last_page(info)
    info['pagination']['last'].match(/page=([0-9\.]+)/)[1].to_i
  end

  def get_products(info)
    info['products'].each do |product|
      product = serialize_product(product)
      DbHandler.save_product(product)
    end
  end

  def serialize_product(info)
    product = {}
    product[:price] = info['price'] * 100
    product[:link] = "https://ad.zanox.com/ppc/?37572583C89486153&ULPe=[[https:#{info['url']}?utm_source=Parcerias_Zanox&utm_medium=publisher_deeplink&utm_campaign=Parcerias_Zanox&origem=zanox]]"
    product[:photo] = "https:#{info['images']['default']}"
    product[:name] = info['details']['Descricao_Resumida']&.first
    product[:store_code] = "centauro-#{info['details']['sku_list']&.first}"    
    product[:brand] = info['details']['Marca']&.first
    product[:seller] = I18n.transliterate(info['details']['NomeSeller']&.first)
    product[:promo] = info['details']['Promoção']&.first
    product[:store_id] = 5
    puts product
    product
  end
end

# product[:stock] = info['details']['Estoque']&.first
# product[:category] = info['details']['CategoriaA2']&.first