require 'nokogiri'
require 'open-uri'
require 'mechanize'

def scrapy
    user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    url = "https://www.musculosnaweb.com.br/suplementos"
    while true
      agent = Mechanize.new
      agent.user_agent = user_agent
      begin
        doc = agent.get(url)
      rescue => e
        sleep 60
        puts 'error, retrying after a min'
        retry
      end
      puts "Scrapping #{url}"
      doc.search('.item').each do |product|
        sup = {}
        unless product.blank?
        #get main info from suplemento on the index products page
          unless  product.search('.regular-price').nil?
            sup[:store_code] = "mw-" + product.search('.regular-price').first.attributes['id'].value.gsub(/\D/, '')
          end
          #this product image has most of product info
          unless product.search('.product-image').nil?
            sup[:link] = product.search('.product-image').first['href']
            sup[:name] = product.search('.product-image').first['title']
            sup[:photo_url] = product.search('.product-image').first.children[1]['src']
          end
          sup[:price] = product.search('.price').first.text.gsub(/\D/,'').to_i   
          # check if suplemento is already on the DB
          if Suplemento.where(store_code: sup[:sku]).empty?
            save(sup)
          else
            update(sup, sup[:sku])
          end
        end
      end
      #search for the next page link 
      if !doc.search('.i-next').first['href'].nil?
        #if exist, go for anothe iteration
        url = doc.search('.i-next').first['href']
      else
        #if next page dont exists, break iteration
        break
      end
    end
  end

  def save(prod)
    sleep 1
    begin
      product = Suplemento.new(
          name:   prod[:name],
          link:   prod[:link],
          store_code:   prod[:sku],
          seller:   prod[:seller],
          sender:   prod[:sender],
          weight: prod[:weight],
          flavor: prod[:flavor],
          brand:  prod[:brand],
          price:  prod[:price],
          photo: prod[:photo_url],
          supershipping: prod[:supershipping],
          promo: prod[:promo],
          prime: prod[:prime],
          store_id: 3
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
    sleep 1
    product = Suplemento.where(store_code: store_code).first
    begin
        product.name = prod[:name]
        product.link = prod[:link]
        product.store_code = prod[:sku]    
        product.seller = prod[:seller]
        product.weight = prod[:weight]
        product.flavor = prod[:flavor]
        product.brand = prod[:brand]
        product.price =  prod[:price]
        product.price_changed = product.price_cents_changed?
        product.photo = prod[:photo_url]
        product.sender = prod[:sender]
        product.supershipping = prod[:supershipping]
        product.promo = prod[:promo]
        product.store_id = 3    
        product.save
    rescue => e
        puts e
        puts product
    end
    puts "Product #{prod[:name]} updated on DB"
  end
  

scrapy()