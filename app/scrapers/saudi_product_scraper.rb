require 'nokogiri'
require 'open-uri'
require 'mechanize'
# scrape to index product page


class SaudiProductScraper
  # Access-Control-Allow-Headers, x-requested-with, x-requested-by
  
  def initialize(options = {})
    @agent = Mechanize.new
    @agent.user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    @store = options[:store]
    @seller = options[:seller]
    @store_id = options[:store_id]
    @store_code = options[:store_code]
    @headers = create_headers()
  end

  def get_product_infos
    puts "Starting crawler"
    check_list = create_list()
    puts "List to scrape created"
    get_api_info(check_list)
    puts "#{@seller} Product Page infos collected"
  end

  def create_list
    Suplemento.where(store_id: @store_id).update_all(checked: false)
    Suplemento.where(store_id: @store_id).order(dependants: :desc)
  end
  
  def get_api_info(check_list)
    check_list.each do |product| 
        product.checked ? (puts "#{product.name} already checked") : api_info = make_request(product) 
        get_products(api_info, product) if api_info
        sleep 1
    end
  end

  def make_request(product)
    api_endpoint = "https://www.#{@store}.com.br/produtojsv2.ashx?g=#{product.auxgrad}&l=&vp=savewhey11"
    referer_adapt = product.link.match(/(?<=produto\/)(.*)(?=&utm)/)
    @headers["referer"] = "https://www.#{@store}.com.br/produto/#{referer_adapt}&vp=savewhey11"
    @agent.request_headers = @headers
    response = @agent.get(api_endpoint)
    JSON.parse(response.body)
  rescue StandardError => e
    puts e
    puts "error.. retrying after a min"
  end
  
  def list_owner?(api_product, product)
    api_product["ID"] == product.store_code.gsub(/#{@store}-/,"").to_i
  end

  def count_dependants(api_info)
    dependants = api_info["lista"].select {|product| product["Disponivel"]}
    dependants.count - 1
  end
  
  def get_products(api_info, product)
    api_info['lista'].each do |api_product|
        if api_product["Disponivel"]
            product_updates = {
                store_id: @store_id,
                store_code: "#{@store_code}-#{api_product['ID']}", 
                weight: api_product["Tamanho"],
                promo: api_product["NrCupom"],
                # only one product in the list is owner of the current loop dependants
                dependants: list_owner?(api_product, product) ? count_dependants(api_info) : 0,
                checked: true
            }
            DbHandler.save_product(product_updates)
        end
    end

  end

  def create_headers
    {
      "authority": "www.#{@store}.com.br",
      "accept": "application/json, text/plain, */*",
      "sec-fetch-dest": "empty",
      "user-agent": "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0",
      "sec-fetch-site": "same-origin",
      "sec-fetch-mode": "cors",
      "accept-language": "en-US,en;q=0.9,la;q=0.8"
    }
  end

end