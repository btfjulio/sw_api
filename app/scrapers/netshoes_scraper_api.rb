require 'nokogiri'
require 'mechanize'

class NetshoesScraperApi

  HEADERS = {
    "authority": "prd-free-mobile-api.ns2online.com.br",
    "content-type": "application/json",
    "uuid": "30c838c0-f999-4734-824f-d99f2c860042_anonymous",
    "storeid": "L_NETSHOES",
    "accept": "*/*",
    "accept-language": "pt-br",
    "accept-encoding": "gzip, deflate, br",
    "x-newrelic-id": "VQEHV15UChAGV1JQAwQCUA==",
    "campaign": "compadi"
  }

  def initialize()
    @agent = create_crawler()
    @page = 1
  end

  def create_crawler
    agent = Mechanize.new
    agent.request_headers = HEADERS
    agent.user_agent = "Netshoes App"  
    agent
  end
  
  def access_api()
    last_page = get_last_page()
    while @page <= last_page
      # break if all_unavailable?(info)
      parsed_json = make_request()
      get_products(parsed_json)
      @page += 1
    end
  end

  def get_products(products_infos)
    products_infos["parentSkus"].each do |product_info|
      if product_info["available"]
        serialized_product = serialize_product(product_info)
        DbHandler.save_product(serialized_product)
      else
        DbHandler.delete_product(serialized_product)
      end
    end
  end

  def get_last_page
    info = make_request()
    info['totalPages']
  end
  
  def serialize_product(product_info)
    {
      store_code: product_info["code"],
      price: product_info["salePrice"],
      photo: "https://static.netshoes.com.br#{product_info["image"]}",
      link: "https://ad.zanox.com/ppc/?37530276C20702613&ULP=[[https://www.netshoes.com.br/#{get_link_piece(product_info["image"], product_info["code"])}?campaign=compadi]]",
      brand: product_info["brand"],
      name: product_info["name"],
      promo: (get_promos(product_info["stamps"]) unless product_info["stamps"].empty?),
      flavor: product_info["flavor"],
      category: product_info["productType"],
      combo: product_info["productType"] == "Kits" ? "true" : "false",
      supershipping: product_info["freeShipping"],
      store_id: 2 
    }
  end

  def get_promos(promos)
    stamps = [
      "2 POR R$ 99,90",
      "3 POR R$ 99,90",
      "3 por 2",
      "4 por R$ 99,90",
      "CUPOM 50%",
      "GANHE MAIS",
      "PROGRESSIVO"
    ]
    discount_promos = promos.filter { |promo| stamps.include?(promo["name"]) }
    discount_promos.empty? ? nil : discount_promos.map { |promo| promo["name"] }.join(' ')
  end

  def get_link_piece(url, code)
    "#{url.match(/(?<=produtos\/)(.*?)(?=\/)/)}-#{code}"
  end

  def make_request
    begin
      retries ||= 0
      api_endpoint = "https://prd-free-mobile-api.ns2online.com.br/suplementos?mi=hm_mob_mntop_S-suple&page=#{@page}"
      response = @agent.get(api_endpoint)
      parsed_response = JSON.parse(response.body)
      raise if parsed_response["code"] == "INTERNAL_SERVER_ERROR"
      parsed_response
    rescue => exception
      sleep 4
      if retries <= 3
        retries += 1
        retry
      end
    end
  end
    

end
