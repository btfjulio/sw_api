class ScrapeJob < ApplicationJob
  queue_as :default

  def perform
    puts "Starting the job"
    sleep 3
    puts "finished"
    true
  end
end
