class UpdatePricesJob < ApplicationJob
  queue_as :default

  # user is to complex and will be sent to redis, and then back to the job
  # from redis to the sidekiq
  # add callback model action
  def perform(serialized_product)
    # Do something later
    product = GlobalID.find(serialized_product)
    product.create_price
    product.delete_old_prices
    product.update_average
  end
end
