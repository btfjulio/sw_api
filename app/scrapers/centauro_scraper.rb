require 'nokogiri'
require 'open-uri'
require 'mechanize'
require_relative 'headless_browser'
# scrape to index product page

class CentauroScraper
  def scrapy
    user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    url = "https://esportes.centauro.com.br/nav/esportes/suplementos/"
    while true
      doc =  Nokogiri::HTML(HeadlessBrowser.initialize_browser(url))
    begin 
      rescue => e
        puts "error.. retrying after a min"
        sleep 60
        retry
      end
      puts "Scrapping #{url}"
      puts doc
      doc.search('.product-card').each do |product|
        sup = {}
        unless product.blank?
          unless product.search('a').first.nil?
            sup[:link] = product.search('a').first['href']
          end
          unless product.search('._xe1nr1').first.nil?
            sup[:name] = product.search('._xe1nr1').first.text
          end
          unless product.search('._9pmwio').first.nil?
            sup[:price] = product.search('._9pmwio').first.text    
          end
          unless product.search('._j96s06').first.nil?
            sup[:photo_url] =  "https:#{product.search('._j96s06').first['src']}"
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
      if !doc.search('._qc114t').first.nil?
        url = "https://centauro.com.br/#{doc.search('._qc114t').first['href']}"
      else
        break
      end
    end
  end
  
  # scrape to show product page
  def prod_scraper(sup)
    sleep rand(1..3)
    begin
      doc =  Nokogiri::HTML(HeadlessBrowser.initialize_browser(sup[:link]))
    rescue => e
      #check if page still avaiable
      puts e
      if e.response_code == '404'
        return sup
      end
      puts "error.. retrying after a min" 
      sleep 60
      retry
    end
    puts "Scrapping #{sup[:name]}"
    unless doc.search('._430e3s').nil?
      unless doc.search('._430e3s').search('small').nil?
        sup[:sku] = doc.search('._430e3s').search('small').first.text.match(/\: ?.*/).to_s.gsub(/\W/,'')
      end
    end
    unless doc.search('._1y15b3k').first.nil?
      sup[:price] =  doc.search('._1y15b3k').text.gsub(/\D/,'')
    end
    unless doc.search('._fynjto').first.nil?
      sup[:seller] = doc.search('._fynjto').first.text
    end 
    unless doc.search('._1irfpnl').first.nil?
      sup[:sender] = doc.search('._1irfpnl').first.text.match(/\: ?.*/).to_s.gsub(/\W/,'')
    end 
    sup
  end
  
  def save(prod)
    begin
      product = Suplemento.new(
          name:   prod[:name],
          link:   "https://ad.zanox.com/ppc/?37530276C20702613&ULP=[[#{prod[:link]}]]",
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
          store_id: 5 
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
        product.link = "https://ad.zanox.com/ppc/?37530276C20702613&ULP=[[#{prod[:link]}]]"
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
        product.store_id = 5    
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
