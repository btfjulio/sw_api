class PricesUpdater

    def start()
        Suplemento.all.each do |suplemento|
            delete_old_prices(suplemento)    
        end
    end

    def delete_old_prices(suplemento)
        while suplemento.prices.length > 30
            suplemento.prices.last.destroy
            puts "Price deleted"
        end
    end
end
