
class DbHandler 

  def self.save_product(product)
    if product[:weight].nil?
      product[:weight] = get_weight(product) 
      # binding.pry if product[:weight].nil?
    end
    collected_product = Suplemento.where(store_code: product[:store_code]).first
    collected_product ? update_product(collected_product, product) : create_product(product)
  end

  def self.delete_product(product)
    collected_product = Suplemento.where(store_code: product[:store_code]).first
    collected_product.destroy if collected_product
  end

  private


  def self.create_product(product)
      new_product = Suplemento.new(product)
      new_product.save!
    # Netshoes marketplace sellers are only shown on product show api endpoint
    if (product[:store_id] == 2)  
      product = get_seller_info(product)
      new_product.update(product) if product
    end
    #get unique brand code used on pictures
    if (product[:brand] && product[:brand_code].nil?)  
      product_brand_code = get_brand_code(product)
      new_product.update(brand_code: product_brand_code)
    end
    puts "Product #{new_product.name} created on DB"
  end

  def self.update_product(collected_product, product)
    product[:average] = updated_average(collected_product)
    product[:price_changed] = check_price(collected_product, product) 
    #get unique brand code used on pictures
    if (product[:brand] && product[:brand_code].nil?)  
      product[:brand_code] = (get_brand_code(product))
    end
    # Netshoes marketplace sellers are only shown on product show api endpoint
    if (product[:store_id] == 2 && product[:price_changed])
      collected_product.update(product)
      # price changes have a good corelation with changing sellers
      product = get_seller_info(product)
    end
    # get seller info returns false if product is not available
    collected_product.update(product) if product
    puts "PRODUCT #{collected_product.name} UPDATED ON DB"
  end
  
  def self.updated_average(product)
    create_price(product) if product.prices.empty?
    if product.price_cents > 0
        product.prices.average(:price).to_i
    end
  end

  def self.check_price(collected_product, product)
    product[:price] == (collected_product[:price_cents] / 100)
  end

  def self.create_price(product)
    Price.create(
      suplemento_id: product.id,
      price: product.price_cents ? product.price_cents : product.price
    )
  end

  def self.get_seller_info(product)
    # scrape the product page api on store
    api_scraper = NetshoesProductScraper.new({
      product: product
    })
    api_scraper.get_product_infos()
  end

  def self.get_brand_code(product)
    product_brand = I18n.transliterate(product[:brand].gsub(' ', ''))
    brand = Brand.search_name(product_brand)&.first
    brand ? brand.store_code : nil 
  end

  def self.get_weight(product)
    name = I18n.transliterate(product[:name])
    weight = name.match(/([0-9](,|.))?([0-9]){1,4}(\s?)(saches|barras|kg|lbs|lb|g|ml|tabs|tabletes|caps|cps|(unidade)s?)/i)
    weight ? weight.to_s.downcase : nil  
  end

end



