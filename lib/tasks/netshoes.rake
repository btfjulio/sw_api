
namespace :netshoes do
    desc 'Scrape netshoes equipment index pages'
    task scrape_equipment_index: :environment do
        index_scraper = Equipment::Netshoes::IndexScraper.new()
        index_scraper.get_products()
    end
    
    desc 'Scrape netshoes suplement index pages'
    task scrape_suplement_index: :environment do
        index_scraper = Suplement::Netshoes::IndexScraper.new()
        index_scraper.get_products()
    end
    
end 