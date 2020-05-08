class PricesUpdater

    def start()
        Suplemento.all.each do |suplemento|
            delete_old_prices(suplemento, 'suplemento')    
        end
    end

    def delete_old_prices(product)
        size = product.prices.count
        while size > 30
            p = product.prices.first
            p.delete
            size = product.prices.count
            puts product.prices.count
            puts "Price from #{product.name} deleted"
        end
    end

    def delete_old_prices_improved(product, query)
        size = product.prices.count
    
        if size > 30
            conn = ActiveRecord::Base.connection
            result = conn.execute "SELECT TOP #{size - 30} FROM prices WHERE #{product}_id = #{product.id}"
            result.delete_all
        end
    end
end
