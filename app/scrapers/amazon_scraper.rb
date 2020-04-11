require_relative 'amazon_api'
require_relative 'db_handler'

class AmazonScraper
  def access_api
    suples = read_json
    api_connection = AmazonApi.new
    until suples.empty?
      items_ids = suples.slice!(0, 10)
      products = api_connection.get_products(items_ids)
      sleep 1
      parse_products(products)
    end
    puts 'Finished to updade data'
  end

  def read_json
    sup_json = File.read('app/scrapers/sup.json')
    parsed_json = JSON.parse(sup_json)
    parsed_json["suplementos"].map! { |s| s['asin'] }
  end

  def parse_products(products)
    products.each do |product|
      if product['Offers'].nil? || check_book(product) || offer['MerchantInfo'].nil?
        puts 'indisponível'
        DbHandler.delete_product({store_code: product['ASIN']})
      else
        serialized_product = serialize_product(product)
        DbHandler.save_product(serialized_product)
      end
    end
  end

  def serialize_product(product)
    offer = product['Offers']['Listings'].first
    item_info = product['ItemInfo']['ProductInfo']
    external_ids = product['ItemInfo']['ExternalIds']
    image = product['Images']
    begin
        {
          price: offer['Price']['DisplayAmount'].gsub(/\D/, ''),
          link: product['DetailPageURL'],
          photo: image.nil? ? nil : image['Primary']['Medium']['URL'],
          name: product['ItemInfo']['Title']['DisplayValue'],
          store_code: product['ASIN'],
          weight: item_info.nil? ? nil : get_info(item_info['Size']),
          brand: get_info(product['ItemInfo']['ByLineInfo']['Brand']),
          seller: offer['MerchantInfo']['Name'],
          flavor: item_info.nil? ? nil : get_info(item_info['Color']),
          ean: external_ids.nil? ? nil : external_ids['EANs']['DisplayValues'].first,
          store_id: 1
        }
    rescue => exception
        binding.pry
    end
  end

  def check_book(product)
    product['ItemInfo']['Title']['DisplayValue'] =~ /Livro/
  end

  def get_info(product_info)
    product_info.nil? ? nil : product_info['DisplayValue']
  end

end
