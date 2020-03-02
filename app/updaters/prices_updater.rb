class PricesUpdater

    def start()
        Suplemento.all.each do |suplemento|
            delete_old_prices(suplemento)    
        end
    end

    def delete_old_prices(suplemento)
        size = suplemento.prices.count
        dif_to_delete = size - 30
        prices_to_delete = suplemento.prices.first(dif_to_delete)
        prices_to_delete.delete_all
        puts suplemento.prices.count
        puts "Price from #{suplemento.name} deleted"
    end
end
