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
end
