class UpdatePricesJob < ApplicationJob
  queue_as :default

  # user is to complex and will be sent to redis, and then back to the job
  # from redis to the sidekiq
  def perform(user_id)
    # Do something later
    user = User.find(user_id)
    puts "performing Clearbit Api for #{user.email}"
    sleep 3
    puts "Done with Clearbit call, enriched #{user.email}!"
  end
end
