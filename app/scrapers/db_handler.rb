class DbHandler
    def self.save_product(product)
        product = Suplemento.where(store_code: product[:sku])
        product.empty? create(product) : update(product)
    end
end