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
    product
  end
  
  def get_api_info
    api_info = make_request()
    serialize_product(api_info)
  end

  def make_request
    api_endpoint = "https://www.netshoes.com.br/frdmprcs/#{@product_store_code}"
    response = @agent.get(api_endpoint)
    JSON.parse(response.body)
  rescue StandardError => e
    puts e
    puts "error.. retrying after a min"
  end
    
  def serialize_product(api_info)
    begin
        product = api_info["itemParents"]&.first["skus"]&.first
        { 
            # brand_code: product["brandId"],
            seller: get_seller(product)
        }
    rescue => exception
        binding.pry
    end
  end

  def get_seller(product)
    if product["sellerId"] == "0"
        "Netshoes"
    else
        product["bestSellerPrices"]&.first["seller"]["name"]
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
