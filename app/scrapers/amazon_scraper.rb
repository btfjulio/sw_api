require 'mechanize'
require 'json'
require "i18n"
require_relative 'amz_api'

class AmazonScraper

    def read_json()
        sup_json = File.read('app/scrapers/sup.json')
        suple = JSON.parse(sup_json)
        suple['suplementos'].each do |suplemento|
            begin
                suplemento = call_api(suplemento)
            rescue => e
                puts e
                retry
            end
            #delete if api answer that offer is not avaiable
            if suplemento == 'delete product'
                delete(suplemento)
                next
            end
            # check if suplemento is already on DB
            unless suplemento[:store_code].nil?
                if Suplemento.where(store_code: suplemento[:store_code]).empty?
                    save(suplemento)
                else
                    update(suplemento, suplemento[:store_code])
                end
            end
        end
        p 'Finished to updade data'
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
                        #check if offer still avaiable
                        if product['Offers']['Offer'].nil? && product['Offers']['TotalOffers'] == '0'
                            #delete offer on DB
                            return 'delete product'                       
                        else
                            prod[:seller] = product['Offers']['Offer']['Merchant']['Name']
                            prod[:prime] = product['Offers']['Offer']['OfferListing']['IsEligibleForPrime']
                            prod[:price] = product['Offers']['Offer']['OfferListing']['Price']['Amount']
                            prod[:supershipping] = product['Offers']['Offer']['OfferListing']['IsEligibleForSuperSaverShipping']
                        end
                    end
                    unless product['MediumImage'].nil?
                        prod[:photo_url] = product['MediumImage']['URL']
                    end
                    prod[:link] = product['DetailPageURL']
                    prod[:store_code] = product['ASIN']
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
            store_code:   prod[:store_code],
            seller:   I18n.transliterate(prod[:seller]),
            weight: prod[:weight],
            flavor: prod[:flavor],
            brand:  prod[:brand],
            price: prod[:price] ,
            photo: prod[:photo_url],
            supershipping: prod[:supershipping],
            prime: prod[:prime],
            store_id: 1 
        )
        product.valid?
        begin
            product.save!
        rescue => e
            puts e
        end        
        puts "Product #{prod[:name]} saved on DB"
    end
    
    def update(prod, store_code)
        product = Suplemento.where(store_code: store_code).first
        begin
            product.name = prod[:name]
            product.link = prod[:link]
            product.store_code = prod[:store_code]    
            product.seller = I18n.transliterate(prod[:seller])
            product.weight = prod[:weight]
            product.flavor = prod[:flavor]
            product.brand = prod[:brand]
            product.price = prod[:price].to_i
            product.price_changed = product.price_cents_changed?
            product.photo = prod[:photo_url]
            product.supershipping = prod[:supershipping]
            product.prime = prod[:prime]
            product.store_id = 1    
        rescue => e
            puts e
        end 
        product.save
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

