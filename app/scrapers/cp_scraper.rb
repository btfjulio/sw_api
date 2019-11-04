require 'nokogiri'
require 'open-uri'
require 'mechanize'
# scrape to index product page


class CpScraper
  def scrapy
    user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    url = "https://www.lojacorpoperfeito.com.br/xml/savewhey.xml"
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
    doc.search('item').each do |product|
      sup = {} 
      unless product.blank?
        unless product.children[1].text.nil?
          sup[:sku] = product.children[1].text
        end
        unless product.children[11].text.nil?
          sup[:link] = product.children[11].text
        end
        unless product.children[3].text.nil?
          sup[:name] = product.children[3].text
        end
        unless product.children[15].text.nil?
          sup[:photo_url] = product.children[15].text
        end
        unless product.children[27].text.nil?
          sup[:brand] = product.children[27].text
        end
        unless product.children[21].text.nil?
          sup[:price] = product.children[21].text
        end
        unless product.children[33].text.nil?
          sup[:weight] = product.children[33].text
        end
        if product.children[19].text != 'in stock'
          delete(sup)
          next
        end
        if Suplemento.where(store_code: sup[:sku]).empty?
          save(sup)
        else
          update(sup, sup[:sku])
        end
      end
    end
  end
  
  def save(prod)
    begin
      product = Suplemento.new(
          name:   prod[:name],
          link:   prod[:link],
          store_code:   `#{prod[:sku]}&utm_source=savewhey&vp=savewhey11`,
          seller:   "Saudi Fitness",
          sender:   "Saudi Fitness",
          weight: prod[:weight],
          flavor: prod[:flavor],
          brand:  prod[:brand],
          price:  prod[:price].gsub(/\D/,'').to_i,
          photo: prod[:photo_url],
          supershipping: prod[:supershipping],
          promo: prod[:promo],
          prime: prod[:prime],
          store_id: 4 
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
        product.link = prod[:link]
        product.store_code = `#{prod[:sku]}&utm_source=savewhey&vp=savewhey11`    
        product.seller = "Saudi Fitness"
        product.sender = "Saudi Fitness"
        product.weight = prod[:weight]
        product.flavor = prod[:flavor]
        product.brand = prod[:brand]
        product.price =  prod[:price].gsub(/\D/,'').to_i
        product.price_changed = product.price_cents_changed?
        product.photo = prod[:photo_url]
        product.supershipping = prod[:supershipping]
        product.promo = prod[:promo]
        product.store_id = 4    
        product.save
    rescue => e
        puts e
        puts product
    end
    puts "Product #{prod[:name]} updated on DB"
  end

  def delete(suplemento)
    sup_to_delete = Suplemento.where(store_code: suplemento['asin']).first  
    unless sup_to_delete.nil?
        Suplemento.destroy(sup_to_delete.id)
        puts "Suplemento #{suplemento['name']} deleted on DB"
    end
  end

end
