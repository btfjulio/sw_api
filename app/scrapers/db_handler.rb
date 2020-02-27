class DbHandler
    def self.save_product(product)
        collected_product = Suplemento.where(store_code: product[:sku])
        if collected_product.empty? 
            collected_product = Suplemento.new(product) 
        else
            collected_product.update!(product)
        end
        collected_product.valid?
        collected_product.save!
        puts "Product #{collected_product.name} saved on DB"
    end
end