# CENTAURO SCRAPERS
namespace :centauro do 
  desc 'Scrape Centauro'
  task get_api_products: :environment do
      cp = Suplement::Centauro::ApiProductScraper.new()
      cp.access_api()
  end
end