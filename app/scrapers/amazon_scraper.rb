require_relative 'amazon_api'
require_relative 'db_handler'

class AmazonScraper
  def access_api
    suples = read_json.reject { |asin| asin == '' }
    api_connection = AmazonApi.new
    until suples.empty?
      items_ids = suples.slice!(0, 10)
      products = api_connection.get_products(items_ids)
      sleep 1
      parse_products(products)
      puts "#{suples.count} missing..."
    end
    puts 'Finished to updade data'
  end

  def read_json
    sup_json = File.read('app/scrapers/sup.json')
    parsed_json = JSON.parse(sup_json)
    parsed_json['suplementos'].map! { |s| s['asin'] }
  end

  def parse_products(products)
    products.each do |product|
      if product['Offers'].nil? || is_book?(product) || product.dig('Offers', 'Listings', 0, 'MerchantInfo').nil?
        puts 'indisponível'
        product[:store_code] = product['ASIN']
        DbDeletingService.new(product).call
      else
        serialized_product = serialize_product(product)
        DbSavingService.new(serialized_product).call
      end
    end
  end

  def serialize_product(product)
    offer = product.dig('Offers', 'Listings', 0)
    item_info = product.dig('ItemInfo', 'ProductInfo')
    external_ids = product.dig('ItemInfo','ExternalIds')
    image = product['Images']
    brand_info = product.dig('ItemInfo','ByLineInfo')
    {
      price: offer.dig('Price', 'DisplayAmount').split(' ').first.gsub(/\D/, '').to_i,
      link: product['DetailPageURL'],
      photo: image.nil? ? nil : image.dig('Primary', 'Medium', 'URL'),
      name: product.dig('ItemInfo', 'Title', 'DisplayValue'),
      store_code: product['ASIN'],
      weight: item_info.nil? ? nil : get_info(item_info['Size']),
      brand: brand_info.nil? ? nil : get_brand_info(brand_info),
      seller: I18n.transliterate(offer.dig('MerchantInfo', 'Name')),
      flavor: item_info.nil? ? nil : item_info.dig('Color', 'DisplayValue'),
      ean: external_ids.nil? ? nil : external_ids.dig('EANs','DisplayValues', 0),
      store_id: 1
    }
  end

  def is_book?(product)
    product.dig('ItemInfo','Title','DisplayValue') =~ /Livro/
  end

  def get_brand_info(brand_info)
    brand_name = brand_info.dig('Brand', 'DisplayValue')
    brand = MatchingBrandService.new(brand_name).call
    brand.present? ? brand : nil
  end

  def get_info(product_info)
    product_info.nil? ? nil : product_info['DisplayValue']
  end
end
