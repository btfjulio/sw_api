class PricesUpdater

    def start()
        Suplemento.all.each do |suplemento|
            delete_old_prices(suplemento)    
        end
    end

    def delete_old_prices(suplemento)
        size = suplemento.prices.count
        dif_to_delete = size - 30
        p = suplemento.prices.first(dif_to_delete)
        p.delete_all
        puts suplemento.prices.count
        puts "Price from #{suplemento.name} deleted"
    end
end
