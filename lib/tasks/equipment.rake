desc 'Scrape Netshoes API'
task scrape_netshoes_equipment_index: :environment do
    api_scraper = Equipment::Netshoes::IndexScraper.new()
    api_scraper.get_products()
end
