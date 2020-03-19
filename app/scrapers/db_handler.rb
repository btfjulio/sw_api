class DbHandler 

  def self.save_product(product)
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
    puts "Product #{new_product.name} created on DB"
  end

  def self.update_product(collected_product, product)
    product[:average] = updated_average(collected_product)
    collected_product.update(product)
    puts "Product #{collected_product.name} updated on DB"
  end
  
  def self.updated_average(product)
    create_price(product) if product.prices.empty?
    if product.price_cents > 0
        product.prices.average(:price).to_i  
    else 
      binding.pry
    end
  end

  def self.create_price(product)
    Price.create(
      suplemento_id: product.id,
      price: product.price_cents ? product.price_cents : product.price
    )
  end
end
