
# every day a price sample is saved
# delete first price if samples size > 30
desc 'Save Prices'
task save_prices: :environment do
    saver = SavePrices.new()
    saver.save_prices()
    updater = PricesUpdater.new()
    updater.start()
end

# populate fake prices in development db
task populate_prices: :environment do
    Suplemento.all.each do |suplemento|
        Price.create({
            suplemento_id: suplemento.id,
            price: suplemento.price_cents * (rand(6..15).to_f / 10)
        })
        suplemento.average = suplemento.prices.average(:price)
        suplemento.save
    end
end