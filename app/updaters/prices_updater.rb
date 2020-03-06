class PricesUpdater

    def start()
        Suplemento.all.each do |suplemento|
            delete_old_prices(suplemento)    
        end
    end

    def delete_old_prices(suplemento)
        size = suplemento.prices.count
        while size > 30
            p = suplemento.prices.first
            p.delete
            size = suplemento.prices.count
            puts suplemento.prices.count
            puts "Price from #{suplemento.name} deleted"
        end
    end

    def delete_old_prices_improved(suplemento)
        size = suplemento.prices.count
        if size > 30
            conn = ActiveRecord::Base.connection
            result = conn.execute "SELECT TOP #{size - 30} FROM prices WHERE suplemento_id = #{suplemento.id}"
            result.delete_all
        end
    end
end
