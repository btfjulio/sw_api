

# desc 'Scrape Netshoes API'
# task scrape_netshoes_equipment_index: :environment do
#     index_scraper = Equipment::Netshoes::IndexScraper.new()
#     index_scraper.get_products()
# end


# desc 'Scrape Netshoes Products API'
# task scrape_netshoes_equipment: :environment do
#     def save_product(product, equipment)
#         if product.class == Hash
#             puts "equipment #{equipment.name} UPDATED on DB"
#             equipment.update(product)
#         else
#             equipment.update({seller: "Netshoes"})
#         end 
#     end

#     Equipment.where(store_id: 2).each do |equipment|
#         api_scraper = NetshoesProductScraper.new({
#             product: equipment
#         })
#         product = api_scraper.get_product_infos()
#         save_product(product, equipment)
#     end
#     puts "All products sellers updated"
# end

# namespace :equipment do
#     task populate_prices: :environment do
#         Equipment.all.each do |equipment|
#             Price.create({
#                 equipment_id: equipment.id,
#                 price: equipment.price * (rand(6..15).to_f / 10)
#             })
#             equipment.average = equipment.prices.average(:price)
#             equipment.save
#         end
#     end
# end
# # populate fake prices in development db
