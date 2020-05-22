
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
    
    desc 'Scrape netshoes suplement index pages'
    task update_suplement: :environment do
        not_updated = Suplemento.where(store_id: 2).where.not('DATE(updated_at) = ?', Date.today)
        not_updated.each do |suplement|
            show_page_scraper = Suplement::Netshoes::ApiProductScraper.new(product: suplement)
            api_info = show_page_scraper.get_product_infos
            api_info ? suplement.update(api_info) : suplement.destroy
        end
    end
    
    desc 'Scrape netshoes suplement index pages'
    task update_equipment: :environment do
        not_updated = Equipment.where.not('DATE(updated_at) = ?', Date.today)
        not_updated.each do |equipment|
            show_page_scraper = Equipment::Netshoes::ApiProductScraper.new(product: equipment)
            api_info = show_page_scraper.get_product_infos
            api_info ? equipment.update(api_info) : equipment.destroy
        end
    end
    
end 