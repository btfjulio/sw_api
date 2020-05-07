desc 'Scrape Netshoes API'
task scrape_netshoes_equipment_index: :environment do
    api_scraper = Equipment::Netshoes::ApiScraper.new()
    api_scraper.access_api()
end


desc 'Scrape Netshoes Products API'
task scrape_netshoes_equipment: :environment do
    def save_product(product, equipment)
        if product.class == Hash
            puts "equipment #{equipment.name} UPDATED on DB"
            equipment.update(product)
        else
            equipment.update({seller: "Netshoes"})
        end 
    end

    Equipment.where(store_id: 2).each do |equipment|
        api_scraper = NetshoesProductScraper.new({
            product: equipment
        })
        product = api_scraper.get_product_infos()
        save_product(product, equipment)
    end
    puts "All products sellers updated"
end
