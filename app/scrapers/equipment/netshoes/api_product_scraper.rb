require 'nokogiri'
require 'open-uri'
require 'mechanize'


class Equipment::Netshoes::ApiProductScraper
  
  def initialize(options = {})
    @agent = Mechanize.new
    @agent.user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    @product = options[:product]
    @product_store_code = options[:product][:store_code]
    @headers = create_headers()
  end

  def get_product_infos
    puts "Get Product #{@product[:name]} API Infos"
    api_info = get_api_info()
    #returns old produt if nothing caught
    api_info ? api_info : @product
  end
  
  def get_api_info
    api_info = make_request()
    product = serialize_product(api_info) if api_info["itemParents"]
    product || false
  end

  def make_request
    retries ||= 0
    api_endpoint = "https://www.netshoes.com.br/frdmprcs/#{@product[:store_code]}"
    sleep 1
    response = @agent.get(api_endpoint)
    return JSON.parse(response.body)
  rescue StandardError => e
    puts e
    if retries <= 3
      retries += 1
      puts "error.. retrying after a min"
      sleep 30
      retry
    end
  end
  
  def serialize_product(api_info)
    equipment = api_info["itemParents"]&.first["skus"]&.first
    available = equipment["bestSellerPrices"]&.first["available"]
    if !available
      false
    else
      get_prod_info(equipment)
    end
  end
  
  def get_prod_info(equipment)
    { 
      free_shipping: equipment["freeShipping"] == "true",
      price: equipment["finalPriceInCents"],
      seller: equipment["bestSellerPrices"]&.first["seller"]["name"] || "Netshoes",
      promo: (
        equipment["itemCloseness"] &&
        equipment["itemCloseness"]["communication"] && 
        equipment["itemCloseness"]["communication"]["stamp"]
        ) || nil
    }
  end

  def create_headers
    {
        "Accept": "*/*",
        "Referer": "https://www.netshoes.com.br/#{@product_store_code}",
        "Sec-Fetch-Dest": "empty",
        "X-Requested-With": "XMLHttpRequest",
        "campaign": "compadi"
    }
  end

end
