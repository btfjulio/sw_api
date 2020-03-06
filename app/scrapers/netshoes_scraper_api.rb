require 'nokogiri'
require_relative 'crawler'
require 'mechanize'

class NetshoesScraperApi
  @@headers = {
    "authority": "prd-free-mobile-api.ns2online.com.br",
    "content-type": "application/json",
    "uuid": "30c838c0-f999-4734-824f-d99f2c860042_anonymous",
    "storeid": "L_NETSHOES",
    "accept": "*/*",
    "accept-language": "pt-br",
    "accept-encoding": "gzip, deflate, br",
    "x-newrelic-id": "VQEHV15UChAGV1JQAwQCUA=="
  }

  def access_api
    agent = Mechanize.new
    user_agent = "Netshoes App"
    agent.request_headers = @@headers
    agent.user_agent = user_agent
    parsed_json = get_api_info(agent)
    products = parsed_json["parentSkus"]
    save_products(products)
  end

  def get_api_info(agent)
    api_endpoint = "https://prd-free-mobile-api.ns2online.com.br/suplementos?mi=hm_mob_mntop_S-suple&page=1"
    response = agent.get(api_endpoint)
    JSON.parse(response.body)
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

  def save_products(products_infos)
    pds = []
    products_infos.each do |product_info|
      unless product_info.nil?
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
    product[:price] = product_info[1]["offers"]&.first["paymentOptions"]["CARTAO_VISA"]["installments"]&.first["value"] * 100
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
