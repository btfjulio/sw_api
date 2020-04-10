require_relative 'amazon_api'

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
      if product['Offers'].nil? || check_book(product)
        puts 'indisponível'
      else
        serialized_product = serialize_product(product)
        puts serialized_product[:store_code]
      end
    end
  end

  def serialize_product(product)
    offer = product['Offers']['Listings'].first
    {
      price: offer['Price']['DisplayAmount'].gsub(/\D/, ''),
      link: product['DetailPageURL'],
      photo: product['Images']['Primary']['Medium']['URL'],
      name: product['ItemInfo']['Title']['DisplayValue'],
      store_code: product['ASIN'],
      weight: get_info(product['ItemInfo']['ProductInfo']['Size']),
      brand: product['ItemInfo']['ByLineInfo']['Brand']['DisplayValue'],
      seller: offer['MerchantInfo']['Name'],
      flavor: get_info(product['ItemInfo']['ProductInfo']['Color']),
      ean: product['ItemInfo']['ExternalIds'].nil? ? nil : product['ItemInfo']['ExternalIds']['EANs'].first,
      store_id: 1
    }
  end

  def check_book(product)
    product['ItemInfo']['Title']['DisplayValue'] =~ /Livro/
  end

  def get_info(product_info)
    product_info.nil? ? nil : product_info['DisplayValue']
  end

end
