desc 'Save Prices'
task save_prices: :environment do
    saver = SavePrices.new()
    saver.save_prices()
end