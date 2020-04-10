class SavePrices
# save current prices 
    def save_prices
        Suplemento.all.each do |product|
            create_price(product)
            average = product.prices.average(:price).to_i
            product.update(
                average: average,
                diff: (product.price_cents - average) / product.price_cents
            )
            puts product
        end
    end

# save prices in a spefic store
    def save_prices_store(store_id)
        Suplemento.where(store_id: store_id).each do |product|
            create_price(product) 
            average = product.prices.average(:price).to_i   
            product.update(
                average: average,
                diff: (product.price_cents - average) / product.price_cents
            )
        end
    end

    def create_price(product)
        Price.create(
            suplemento_id: product.id,
            price: product.price_cents
        )
    end
end

