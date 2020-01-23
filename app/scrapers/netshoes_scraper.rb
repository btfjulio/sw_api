require 'nokogiri'
require 'open-uri'
require 'mechanize'
require_relative 'netshoes_api'


class NetshoesScraper

  def scrapy
    # url = 'https://www.netshoes.com.br/suplementos?campaign=compadi&nsCat=Artificial&page=14'
    url = "https://www.netshoes.com.br/suplementos?campaign=compadi"
    agent = create_agent()
    doc = get_page(agent, url)
    page = 1
    last_page = get_tag_content('.last',doc, {method: 'text' }).to_i
    while page <= last_page
      doc = get_page(agent, "#{url}&page=#{page}")
      puts "Scrapping #{url}&page=#{page}"
      doc.search('.item-card').each do |product|
        sup = {}
        unless product.blank?
          sup[:sku] = product['parent-sku']
          sup[:link] = "https:#{get_tag_content('.item-card__description__product-name', product, { attrib: 'href' })}" 
          sup[:name] = get_tag_content('.item-card__description__product-name', product, { method: 'text' }) 
          sup[:photo_url] = get_tag_content('.item-card__images__image-link img', product, { attrib: 'data-src' }) 
          sup = prod_scraper(sup, agent)
          if sup == 'delete'
            delete(product['parent-sku'])
          elsif Suplemento.where(store_code: sup[:sku]).empty?
            save(sup)
          else
            update(sup, sup[:sku])
          end
        end
      end
      page = page + 1
    end
  end
  
  # scrape to show product page
  def prod_scraper(sup, agent) 
    doc = get_page(agent, "#{sup[:link]}?campaign=compadi")
    if doc 
      puts "Scrapping #{sup[:name]}"
      sup[:price] = get_tag_content('.default-price', doc, { method: 'text' })
      sup[:sender] = get_tag_content('.dlvr', doc, { method: 'text' })
      sup[:flavor] = get_tag_content('.sku-select .item a', doc, { method: 'text' })
      sup[:promo] = get_tag_content('.badge-item', doc, { method: 'text' })
      sup[:seller] = get_tag_content('.product__seller_name span', doc, { method: 'text' }) || 'Netshoes'   
      return 'delete' if out_stock?(doc)
    else
      return sup
    end
    # simulates client side requests from netshoes api
    connect_to_api(sup)
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
    puts "Product #{prod[:name]} updated on DattribB"
  end
  
  def delete(sup_code)
    sup_to_delete = Suplemento.where(store_code: sup_code).first
    unless sup_to_delete.nil?
      puts "Suplemento #{sup_to_delete['name']} deleted on DB"
      sup_to_delete.destroy
      sleep 3
    end
  end
  
  def out_stock?(doc)
    first_tag_available = get_tag_content('.tell-me-button-wrapper .title', doc, { method: 'text' }) 
    return true if first_tag_available && first_tag_available == "Produto indisponível" 
    second_tag_available = get_tag_content('.text-not-avaliable', doc)
    return true if second_tag_available && second_tag_available.match(/acabou/)
  end
  
  def create_agent()
    agent = Mechanize.new
    user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    agent.user_agent = user_agent
    agent
  end
  
  def get_tag_content(tag, doc, options = {})
    unless doc.search(tag).first.nil?
      if options[:method] && options[:attrib]
        doc.search(tag).first.text[options[:attrib]].strip()
      elsif options[:method]
        doc.search(tag).first.text.strip()
      elsif options[:attrib]
        doc.search(tag).first[options[:attrib]]
      else
        doc.search(tag).first
      end
    end
  end
  
  def get_page(agent, url)
    begin 
      retries ||= 0
      return agent.get(url)
    rescue => e
      puts "error.. retrying after a min"
      sleep 3
      if retries <= 1
        retries += 1
        retry
      end
    end
  end
  
  def connect_to_api(sup)
    begin
      sup = NetshoesApi.new().access_api(sup)
    rescue => e
      sleep 3
      puts 'problem in the netshoes api'
      retry
    end
  end

end
