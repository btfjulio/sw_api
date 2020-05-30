require 'nokogiri'
require 'open-uri'
require 'mechanize'
# scrape to index product page
# rake collect_sup_extra_infos

class BaseExtraInfoScraper
  # Access-Control-Allow-Headers, x-requested-with, x-requested-by

  def initialize(options = {})
    @agent = Mechanize.new
    @agent.user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    @store = options[:store]
    @store_code = options[:store_code]
    @headers = create_headers
    last_code = BaseSuplement
            .where("product_code IS NOT NULL")
            .order(product_code: :desc)
            .limit(1)
            .first
    @current_code = last_code || 1
  end

  def get_product_infos
    puts "Starting crawler"
    BaseSuplement.all.update_all(checked: false, product_code: nil)
    puts "List to scrape created"
    get_api_info
    puts "#{@seller} Product Page infos collected"
  end

  def get_api_info
    BaseSuplement.all.each do |product|
      current_suplement = BaseSuplement.find(product.id)
      if current_suplement.checked 
        puts "-------------------------------"
        puts "#{product.name} already checked"
        puts "-------------------------------"
      else
        puts "#{product.name} ainda não checado"
        api_info = make_request(product)
        get_products(api_info, product) if api_info
        sleep 1
      end
    end
  end

  def make_request(product)
    api_endpoint = "https://www.#{@store}.com.br/produtojsv2.ashx?g=#{product.auxgrad}&l=&vp=savewhey11"
    referer_adapt = product.link.match(%r{(?<=produto/)(.*)(?=&utm)})
    @headers["referer"] = "https://www.#{@store}.com.br/produto/#{referer_adapt}&vp=savewhey11"
    @agent.request_headers = @headers
    response = @agent.get(api_endpoint)
    JSON.parse(response.body)
  rescue StandardError => e
    puts e
    puts "error.. retrying after a min"
    sleep 5
  end

  def get_products(api_info, product)
    api_info['lista'].each do |api_product|
      store_code = "#{@store_code}-#{api_product['ID']}"
      db_product = BaseSuplement.where(store_code: store_code).first
      if db_product.nil?
        puts "Suplement not on DB"
      elsif db_product.checked || db_product.product_code 
        puts "#{product.name} already checked"
      else
        db_product.update(
          store_code: store_code,
          weight: api_product["Tamanho"],
          product_code: @current_code,
          # sup_photos_attributes: create_photos_array(api_product["ImagensAdicionais"]),
          checked: true
        )
        puts "PRODUCT #{db_product.name} UPDATED ON DB"
      end
    end
    @current_code += 1
  end

  def create_photos_array(product_photos)
    photos = []
    product_photos.each do |photo_category|
      photo_category["Tamanhos"].each do |photo|
        photos << { 
          name: photo_category["Tipo"], 
          size: photo["Tamanho"], 
          url: Rails.env.production? ? convert_image(photo["URL"]) :  photo["URL"]
        }
      end
    end
    photos
  end


  def convert_image(image_address)
    if image_address.match(/save-whey/).nil?
      begin
          URI.open(image_address)
          uploaded_image = Cloudinary::Uploader.upload(image_address)
          return uploaded_image["secure_url"]    
      rescue => exception
          return nil
      end
    else
      image_address
    end
  end


  def create_headers
    {
      "authority": "www.#{@store}.com.br",
      "accept": "application/json, text/plain, */*",
      "sec-fetch-dest": "empty",
      "user-agent": "Mozilla/5.0 (Linux; U; Android 4.4.2; en-us; SCH-I535 Build/KOT49H) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
      "sec-fetch-site": "same-origin",
      "sec-fetch-mode": "cors",
      "accept-language": "en-US,en;q=0.9,la;q=0.8"
    }
  end
end
