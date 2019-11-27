require 'nokogiri'
require 'open-uri'
require 'mechanize'

# scrape to index product page

class AmericanasScraper
  def scrapy
    user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    url = "https://www.americanas.com.br/busca/suplementos?conteudo=suplementos"
    while true
      agent = Mechanize.new
      agent.user_agent = user_agent
      begin 
        doc = agent.get(url)
      rescue => e
        puts "error.. retrying after a min"
        sleep 60
        retry
      end
      puts "Scrapping #{url}"
      doc.search('.product-grid-item').each do |product|
        sup = {}
        binding.pry
        unless product.blank?
          unless product['parent-sku'].nil?
            sup[:sku] = product['parent-sku']
          end
          unless product.search('.item-card__description__product-name').first['href'].nil?
            sup[:link] = "https:#{product.search('.item-card__description__product-name').first['href']}"
          end
          unless product.search('.item-card__description__product-name').first.nil?
            sup[:name] = product.search('.item-card__description__product-name').text
          end
          unless product.search('.item-card__images__image-link').first.nil?
            sup[:photo_url] = product.search('.item-card__images__image-link').first.search('img').first['data-src']
          end
          sup = prod_scraper(sup)
          if sup == 'delete'     
            delete(product['parent-sku'])
            break
          end 
          if Suplemento.where(store_code: sup[:sku]).empty?
            save(sup)
          else
            update(sup, sup[:sku])
          end
        end
      end
      if !doc.search('.pagination a').search('.next').nil?
        url = "https:#{doc.search('.pagination').search('.next').first['href']}"
      else
        break
      end
    end
  end
  
  # scrape to show product page
  def prod_scraper(sup)
    sleep rand(1..3)
    agent = Mechanize.new
    begin
      doc = agent.get("#{sup[:link]}?campaign=compadi")
    rescue => e
      #check if page still avaiable
    if e.response_code == '404'
        return sup
    end
      puts "error.. retrying after a min" 
      puts e
      sleep 60
    retry
    end
    puts "Scrapping #{sup[:name]}"
    unless doc.search('.default-price').first.nil?
      sup[:price] = doc.search('.default-price').first.text
    end
    unless doc.search('.product-seller-name').first.nil?
      sup[:seller] = doc.search('.product-seller-name').children.first.text
    end 
    unless doc.search('.dlvr').first.nil?
      sup[:sender] = doc.search('.dlvr').first.text
    end
    unless doc.search('.tell-me-button-wrapper').first.nil?
      unless doc.search('.tell-me-button-wrapper').children.first.nil?
        return 'delete' if doc.search('.tell-me-button-wrapper').children.first.text == "Produto indisponível"
      end
    end
    unless doc.search('.show-seller-name').first.nil?
      sup[:seller] =  doc.search('.show-seller-name').first.text
      sup[:sender] =  doc.search('.show-seller-name').first.text
    end
    unless doc.search('.sku-select').search('.content').first.nil?
      sup[:flavor] = doc.search('.sku-select').search('.item a').first.text
    end
    unless doc.search('.badge-item').first.nil?
      sup[:promo] = doc.search('.badge-item').first.text
    end
    if doc.search('.tag-shipping').empty?
      sup[:supershipping] = false
    else
      sup[:supershipping] = true
    end  
    binding.pry
    sup
  end
  
  def save(prod)
    begin
      product = Suplemento.new(
          name:   prod[:name],
          link:   "https://ad.zanox.com/ppc/?37530276C20702613&ULP=[[#{prod[:link]}?campaign=compadi]]",
          store_code:   prod[:sku],
          seller:   prod[:seller],
          sender:   prod[:sender],
          weight: prod[:weight],
          flavor: prod[:flavor],
          brand:  prod[:brand],
          price:  prod[:price].gsub(/\D/,'').to_i,
          photo: prod[:photo_url],
          supershipping: prod[:supershipping],
          promo: prod[:promo],
          prime: prod[:prime],
          store_id: 2 
      ) 
      product.valid?
      product.save!
    rescue => e
      puts e
      puts product
    end        
    puts "Product #{prod[:name]} saved on DB"
  end
  
  def update(prod, store_code)
    product = Suplemento.where(store_code: store_code).first
    begin
        product.name = prod[:name]
        product.link = "https://ad.zanox.com/ppc/?37530276C20702613&ULP=[[#{prod[:link]}?campaign=compadi]]"
        product.store_code = prod[:sku]    
        product.seller = prod[:seller]
        product.weight = prod[:weight]
        product.flavor = prod[:flavor]
        product.brand = prod[:brand]
        product.price =  prod[:price].gsub(/\D/,'').to_i
        product.price_changed = product.price_cents_changed?
        product.photo = prod[:photo_url]
        product.sender = prod[:sender]
        product.supershipping = prod[:supershipping]
        product.promo = prod[:promo]
        product.store_id = 2    
        product.save
    rescue => e
        puts e
        puts product
    end
    puts "Product #{prod[:name]} updated on DB"
  end

  def delete(sup_code)
    sup_to_delete = Suplemento.where(store_code: sup_code).first
    unless sup_to_delete.nil?
      puts "Suplemento #{sup_to_delete['name']} deleted on DB"
      sup_to_delete.destroy
      sleep 3
    end
end

end

am = AmericanasScraper.new()
am.scrapy()
