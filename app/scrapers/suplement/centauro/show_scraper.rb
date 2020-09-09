require 'nokogiri'
require 'open-uri'
require 'mechanize'

class Suplement::Netshoes::ApiProductScraper
  def initialize(options = {})
    @agent = Mechanize.new
    @agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0'
    @product = options[:product]
    @product_store_code = options[:product][:store_code]
    @headers = create_headers
  end

  def get_product_infos
    puts "Get Product #{@product[:name]} API Infos"
    api_info = get_api_info
    # returns old produt if nothing caught
    api_info || false
  end

  def get_api_info
    api_info = make_request
    product = serialize_product(api_info) if api_info['itemParents']
    product || false
  end

  def make_request
    retries ||= 0
    api_endpoint = "https://www.netshoes.com.br/frdmprcs/#{@product[:store_code]}"
    response = @agent.get(api_endpoint)
    JSON.parse(response.body)
  rescue StandardError => e
    puts e
    if retries <= 3
      retries += 1
      puts 'error.. retrying after a min'
      sleep 30
      retry
    end
  end

  def serialize_product(api_info)
    suplement = api_info['itemParents']&.first['skus']&.first
    available = suplement['bestSellerPrices']&.first['available']
    if !available
      false
    else
      prod_info = get_prod_info(suplement)
      # add seller id if product not sold by Netshoes
      prod_info[:link] = set_new_link(suplement) unless prod_info[:seller] == 'Netshoes'
      prod_info
    end
  end

  def set_new_link(api_info)
    seller_id = api_info['bestSellerPrices']&.first['seller']['id']
    @product[:link].gsub('?campaign=compadi', "?sellerId=#{seller_id}&campaign=compadi")
  end

  def get_prod_info(suplement)
    {
      store_id: 2,
      supershipping: suplement['freeShipping'],
      price: suplement['finalPriceInCents'],
      seller: suplement['bestSellerPrices']&.first['seller']['name'] || 'Netshoes',
      promo: (
        suplement['itemCloseness'] &&
        suplement['itemCloseness']['communication'] &&
        suplement['itemCloseness']['communication']['stamp']
      ) || nil
    }
  end

  def create_headers
    {
      "origin": "https://www.centauro.com.br",
      "sec-fetch-site": "same-site" ,
      "sec-fetch-mode": "cors" ,
      "sec-fetch-dest": "empty" ,
      "authority": "apigateway.centauro.com.br" ,
      "accept": "application/json, text/plain, */*" ,
      "x-cv-id": "7" ,
      "authorization": "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcGlnYXRld2F5LmRjLnNibmV0Iiwic3ViIjoid3d3LmNlbnRhdXJvLmNvbS5iciIsImlhdCI6MTUxNjIzOTAyMiwiY2xpZW50X2lkIjoiZTU3Nzk3ZDYtN2Y3Mi00MzMwLWJjOTItOTM3MWRiNjI0YjQ5In0.Mc2PpOJwltFymE3He95TpGTBPDAbhmxNw-cJEsYTghnGefWwhyiD--EopZquF2uH0bdF7K95SkK5RNaZ05Mh3ShuTbqPtD8D7kSr_zQO80nAyIHleLwQzrqrn5GF9piwVSt7YfVDWxj8rNA5HlXQpdTuu0vEUjHQk4hpapB8MtmE1qg9-bymyhD4Hm7x2XHMa-4AtPxhBotPBUwQKWNTbh3OUbCAETknA2tnwfFCSSS3nXot6Icuwx3hvtnkFTk3XitjPwLZ8xTlIJ5Uyk8MjjdG-poMFHKLrdvF7YzhAHUoNn-9Y91jIaYrSA_hDjgb-1y25Jw7UR_lO5F3ceSimg" ,
      "referer": "#{@product[:link]}" ,
      "accept-language": "en-US,en;q=0.9"
    }
  end
end


