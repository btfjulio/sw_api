require 'pry'
require 'nokogiri'
require 'open-uri'
require 'mechanize'
require_relative 'amz_api'

def scrapy
    user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    url = "https://www.amazon.com.br/s?bbn=16769353011&rh=n%3A16215417011%2Cn%3A%2116215418011%2Cn%3A16769353011"
    while true
        agent = Mechanize.new
        agent.user_agent = user_agent
        doc = agent.get(url)
        puts "Scrapping #{url}"
        doc.search('.s-result-item').each do |product|
            sup = {}
            unless product.blank?
                unless product['data-asin'].nil?
                    sup[:asin] = product['data-asin']
                end
                unless product.search('.a-link-normal').nil?
                    sup[:link] = "https://www.amazon.com.br#{product.search('.a-link-normal').first['href']}"
                end
                unless product.search('.a-text-normal').first.nil?
                    sup[:name] = product.search('.a-text-normal').first.text.strip
                end
                unless product.search('.a-price-whole').first.nil?
                    sup[:price] = "#{product.search('.a-price-whole').first.text.strip}#{product.search('.a-price-fraction').first.text}"
                end
                api_response = call_api(sup)
                if Suplemento.where(store_code: sup[:asin]).empty?
                    save(api_response)
                else
                    update(api_response, sup[:asin])
                end
            end
        end
        if !doc.search('.a-last a').empty?
           url = "https://www.amazon.com.br#{doc.search('.a-last a').first['href']}"
        elsif doc.search('.s-result-item').length > 4
           break
        else
            puts 'puts nothing returned sleepping for 10 min..'
            sleep 3600
            puts 'trying again'
        end
    end
end

def call_api(sup)
    search = AmazonAPI.new
    url = search.item_look_up(sup[:asin])
    begin 
        response = HTTParty.get(url)
    rescue => e
        binding.pry
        retry
    end
    unless response['ItemLookupResponse'].nil?
        unless response['ItemLookupResponse']['Items'].nil?
            product = response['ItemLookupResponse']['Items']['Item']
            prod = {}
            prod[:name] = sup[:name]
            unless product.nil?
                unless product['Offers'].nil?
                    unless product['Offers']['Offer'].nil?
                        prod[:seller] = product['Offers']['Offer']['Merchant']['Name']
                        prod[:prime] = product['Offers']['Offer']['OfferListing']['IsEligibleForPrime']
                        prod[:price] = product['Offers']['Offer']['OfferListing']['Price']['Amount']
                        prod[:supershipping] = product['Offers']['Offer']['OfferListing']['IsEligibleForSuperSaverShipping']
                    end
                end
                prod[:asin] = product['ASIN']
                prod[:weight] = product['ItemAttributes']['Size']
                prod[:flavor] = product['ItemAttributes']['Color']
                prod[:brand] = product['ItemAttributes']['Brand']
                sleep 1
                return prod
            end
        end
    end
    sup
end

def save(prod)
    product = Suplemento.new(
        name:   prod[:name],
        link:   prod[:link],
        store_code:   prod[:asin],
        seller:   prod[:seller],
        weight: prod[:weight],
        flavor: prod[:flavor],
        brand:  prod[:brand],
        price: Money.new(prod[:price]),
        store_id: 1
    )
    product.valid?
    begin
        product.save!
    rescue => e
        binding.pry
    end        
    puts "Product #{prod[:name]} saved on DB"
end

def update(prod, store_code)
    product = Suplemento.where(store_code: store_code).first
    begin
        product.name = prod[:name]
        product.link = prod[:link]
        product.store_code = prod[:asin]    
        product.seller = prod[:seller]
        product.weight = prod[:weight]
        product.flavor = prod[:flavor]
        product.brand = prod[:brand]
        product.price = Money.new(prod[:price])
        product.store_id = 1    
    rescue => e
        binding.pry
    end 
    puts product.price_changed?
    product.save
    puts "Product #{prod[:name]} updated on DB"
end

scrapy()