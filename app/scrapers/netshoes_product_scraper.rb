require 'nokogiri'
require 'open-uri'
require 'mechanize'
# scrape to index product page


class NetshoesProductScraper
  # Access-Control-Allow-Headers, x-requested-with, x-requested-by
  
  def initialize(options = {})
    @agent = Mechanize.new
    @agent.user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    @product = options[:product]
    @product_store_code = @product[:store_code]
    @headers = create_headers()
  end

  def get_product_infos
    puts "Get Product #{@product[:name]} API Infos"
    product = get_api_info()
    puts "#{@seller} Product Page infos collected"
    #returns old produt if nothing caught
    product ? product : @product
  end
  
  def get_api_info
    api_info = make_request()
    serialize_product(api_info) if api_info["itemParents"]
  end

  def make_request
    retries ||= 0
    api_endpoint = "https://www.netshoes.com.br/frdmprcs/#{@product_store_code}"
    response = @agent.get(api_endpoint)
    parsed_response = JSON.parse(response.body)
    parsed_response
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
    product = api_info["itemParents"]&.first["skus"]&.first
    available = product["bestSellerPrices"]&.first["available"]
    if available == false
      false
    else
      { seller: product["bestSellerPrices"]&.first["seller"]["name"] }
    end
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
