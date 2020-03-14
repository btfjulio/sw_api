class DbHandler
    def self.save_product(product)
        collected_product = Suplemento.where(store_code: product[:store_code]).first
        collected_product ?  update_product(collected_product, product) : create_product(product)
    end
    
    private
    
    def self.create_product(product)
        new_product = Suplemento.new(product) 
        new_product.save! 
        puts "Product #{new_product.name} created on DB"
    end
    
    def self.update_product(collected_product, product)
        product[:diff] = updated_diff(collected_product)
        collected_product.update(product)
        puts "Product #{collected_product.name} updated on DB"
    end

    def self.updated_diff(product)
        if product.prices.empty?
            create_price(product)
        end
        average = product.prices.average(:price).to_i
        (product.price_cents - average) / product.price_cents
    end

    def self.create_price(product)
        Price.create(
            suplemento_id: product.id,
            price: product.price_cents
        )
    end
end