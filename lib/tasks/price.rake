# every day a price sample is saved
# delete first price if samples size > 30
desc 'Save Prices'
task save_prices: :environment do
  def update_all(model)
    model.all.each do |product|
      product.update_prices
    end
  end
  update_all(Suplemento)
  update_all(Equipment)
end

namespace :product do
  desc 'Update singular product price'
  task :update_price, [:product_id] => :environment  do |t, args|
    product = Suplemento.find(args[:product_id])
    UpdatePricesJob.perform_now(product.to_global_id.to_s)
  end

  desc 'Updating all prices on DB'
  task update_all_prices: :environment do
    def update_all(model)
      model.all.each do |product|
        UpdatePricesJob.perform_later(
          product.to_global_id.to_s
        )
      end
    end
    update_all(Suplemento)
    update_all(Equipment)
  end
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
