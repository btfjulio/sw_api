# class DbHandler
#     def self.save_product(product)
#         product = Suplemento.where(store_code: product[:sku])
#         product.empty? create(product) : update(product)
#     end

#     private

#     def create(product)
#      begin
#       product = Suplemento.new()
#         name:   prod[:name],
#         link:   "https://ad.zanox.com/ppc/?37530276C20702613&ULP=[[#{prod[:link]}]]",
#         store_code:   prod[:sku],
#         seller:   I18n.transliterate(prod[:seller]),
#         sender:   prod[:sender],
#         weight: prod[:weight],
#         flavor: prod[:flavor],
#         brand:  prod[:brand],
#         price:  prod[:price].gsub(/\D/,'').to_i,
#         photo: prod[:photo_url],
#         supershipping: prod[:supershipping],
#         promo: prod[:promo],
#         prime: prod[:prime],
#         store_id: 2 
#       ) 
#       product.valid?
#       product.save!
#     rescue => e
#       puts e
#       puts product
#     end        
#     puts "Product #{prod[:name]} saved on DB"
#     end
# end