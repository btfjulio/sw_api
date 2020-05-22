
namespace :netshoes do
    desc 'Scrape netshoes equipment index pages'
    task scrape_equipment_index: :environment do
        index_scraper = Equipment::Netshoes::IndexScraper.new()
        index_scraper.get_products()
    end
    
end 