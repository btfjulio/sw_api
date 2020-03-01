class PricesUpdater

    def start()
        Suplemento.all.each do |suplemento|
            delete_old_prices(suplemento)    
        end
    end

    def delete_old_prices(suplemento)
        while suplemento.prices.length > 30
            p = suplemento.prices.first
            p.delete
            puts suplemento.prices.length
            puts "Price from #{suplemento.name} deleted"
        end
    end
end
