# require_relative 'crawler'
# require_relative 'netshoes_api'
# require "i18n"


# class NetshoesScraper

#   def scrapy
#     url = "https://www.netshoes.com.br/suplementos?campaign=compadi"
#     crawler = Crawler.new()
#     doc = crawler.get_page(url)
#     page = 1
#     last_page = crawler.get_content('.last', doc) { |content| content.text.strip().to_i }
#     while page <= last_page
#       doc = crawler.get_page("#{url}&page=#{page}")
#       puts "Scrapping #{url}&page=#{page}"
#       crawler.get_products(doc, '.item-card').each do |product|
#         unless product.blank?
#           sup = prod_scraper(product, crawler)
#           if sup == 'delete'
#             delete(product['parent-sku'])
#           elsif Suplemento.where(store_code: sup[:sku]).empty?
#             save(sup)
#           else
#             update(sup, sup[:sku])
#           end
#         end
#       end
#       page = page + 1
#     end

#   end


#   # scrape selectors to scrape products
#   def prod_scraper(product, crawler)
#     sup = {} 
#     sup[:sku] = crawler.get_attribute(product, 'parent-sku')
#     sup[:link] = "https:#{crawler.get_content('.item-card__description__product-name', product, { attrib: 'href' })}?campaign=compadi" 
#     sup[:name] = crawler.get_content('.item-card__description__product-name', product) { |content| content.text.strip() }
#     sup[:photo_url] = crawler.get_content('.item-card__images__image-link img', product, { attrib: 'data-src' }) 
#     doc = crawler.get_page(sup[:link])
#     if doc 
#       puts "Scrapping #{sup[:name]}"
#       sup[:price] = crawler.get_content('.default-price', doc) { |content| content.text.strip() }
#       sup[:sender] = crawler.get_content('.dlvr', doc) { |content| content.text.strip() }
#       sup[:flavor] = crawler.get_content('.sku-select .item a', doc) { |content| content.text.strip() }
#       sup[:promo] = crawler.get_content('.badge-item', doc) { |content| content.text.strip() }
#       sup[:seller] = crawler.get_content('.product__seller_name span', doc) { |content| content.text.strip() } || 'Netshoes'   
#       return 'delete' if out_stock?(crawler, doc)
#     else
#       return sup
#     end
#     connect_to_api(sup)
#   end
  
  
#   def out_stock?(crawler, doc)
#     first_tag_available = crawler.get_content('.tell-me-button-wrapper .title', doc) { |content| content.text.strip() }
#     return true if first_tag_available && first_tag_available == "Produto indisponível" 
#     second_tag_available = crawler.get_content('.text-not-avaliable', doc)
#     return true if second_tag_available && second_tag_available.match(/acabou/)
#   end
  
#   # simulates client side requests from netshoes api
#   def connect_to_api(sup)
#     begin
#       sup = NetshoesApi.new().access_api(sup)
#     rescue => e
#       sleep 3
#       puts 'problem in the netshoes api'
#       retry
#     end
#   end
  
#   def save(prod)
#     begin
#       product = Suplemento.new(
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
#   end

#   def update(prod, store_code)
#     product = Suplemento.where(store_code: store_code).first
#     begin
#       product.name = prod[:name]
#       product.link = "https://ad.zanox.com/ppc/?37530276C20702613&ULP=[[#{prod[:link]}]]" 
#       product.store_code = prod[:sku]    
#       product.seller = I18n.transliterate(prod[:seller])
#       product.weight = prod[:weight]
#       product.flavor = prod[:flavor]
#       product.brand = prod[:brand]
#       product.price =  prod[:price].gsub(/\D/,'').to_i
#       product.price_changed = product.price_cents_changed?
#       product.photo = prod[:photo_url]
#       product.sender = prod[:sender]
#       product.supershipping = prod[:supershipping]
#       product.promo = prod[:promo]
#       product.store_id = 2    
#       product.save
#     rescue => e
#       puts e
#       puts product
#     end
#     puts "Product #{prod[:name]} updated on DattribB"
#   end
  
#   def delete(sup_code)
#     sup_to_delete = Suplemento.where(store_code: sup_code).first
#     unless sup_to_delete.nil?
#       puts "Suplemento #{sup_to_delete['name']} deleted on DB"
#       sup_to_delete.destroy
#       sleep 3
#     end
#   end
  
# end
