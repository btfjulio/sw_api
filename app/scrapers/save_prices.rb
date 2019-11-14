class SavePrices
    def save_prices
        Suplemento.all.each do |sup|
            p = Price.new()
            p.suplemento_id = sup.id
            p.price = sup.price_cents
            p.save
            sup.average = sup.prices.average(:price).to_i
            sup.diff = (sup.price_cents - (sup.average || 0))/ (sup.price_cents != 0 ? sup.price_cents/100 : 1)
            sup.save
            p p
        end
    end
end

