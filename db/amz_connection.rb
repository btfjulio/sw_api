require 'nokogiri'
require 'mechanize'
require_relative 'amz_api'
require 'json'

def read_json()
    sup_json = File.read('db/sup.json')
    suple = JSON.parse(sup_json)
    suple['suplementos'].each do |suplemento|
        api_response = call_api(suplemento)
        if Suplemento.where(store_code: suplemento['asin']).empty?
            save(api_response)
        else
            update(api_response, suplemento['asin'])
        end
    end
end

def call_api(sup)
    search = AmazonAPI.new
    url = search.item_look_up(sup['asin'])
    begin 
        response = HTTParty.get(url)
    rescue => e
        retry
    end
    unless response['ItemLookupResponse'].nil?
        unless response['ItemLookupResponse']['Items'].nil?
            product = response['ItemLookupResponse']['Items']['Item']
            prod = {}
            prod[:name] = sup['name']
            unless product.nil?
                unless product['Offers'].nil?
                    unless product['Offers']['Offer'].nil?
                        prod[:seller] = product['Offers']['Offer']['Merchant']['Name']
                        prod[:prime] = product['Offers']['Offer']['OfferListing']['IsEligibleForPrime']
                        prod[:price] = product['Offers']['Offer']['OfferListing']['Price']['Amount']
                        prod[:supershipping] = product['Offers']['Offer']['OfferListing']['IsEligibleForSuperSaverShipping']
                    end
                end
                unless product['ImageSets']['ImageSet'].nil?
                    prod[:photo_url] = product['ImageSets']['ImageSet'][0]['MediumImage']['URL']
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
        photo: prod[:photo],
        store_id: 1
    )
    product.valid?
    begin
        product.save!
    rescue => e
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
        product.photo = prod[:photo],
        product.store_id = 1    
    rescue => e
    end 
    puts product.price_cents_changed?
    product.save
    puts "Product #{prod[:name]} updated on DB"
end

read_json()