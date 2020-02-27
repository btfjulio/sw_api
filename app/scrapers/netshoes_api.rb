require 'nokogiri'
require_relative 'crawler'
require 'mechanize'

class NetshoesApi 

    @@headers = {
        "accept":"text/javascript, text/html, application/xml, text/xml, */*",
        "accept-language":"en-US,en;q=0.9,la;q=0.8",
        "cache-control":"no-store, no-cache, must-revalidate",
        "campaign":"",
        "content-type":"application/x-www-form-urlencoded",
        "sec-fetch-mode":"cors",
        "sec-fetch-site":"same-origin",
        "storeid":"L_NETSHOES",
        "x-newrelic-id":"VQEHV15UChAGV1JQAwQCUA==",
        "x-requested-with":"XMLHttpRequest"
    }
    

    def access_api(sup)
        agent = Mechanize.new
        user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
        agent.request_headers = @@headers
        agent.user_agent = user_agent
        sup = get_api_info(sup, agent)
        sup[:supershipping]  = get_free_delivery(sup, agent)
        sup
    end

    def get_free_delivery(sup, agent)
        api_endpoint = "https://www.netshoes.com.br/promotion/shipping/#{sup[:sku_ref]}/sellers/#{sup[:seller_code]}/zipCodes/05027020"
        response = agent.get(api_endpoint, referer = ["https://www.netshoes.com.br/suplementos"])
        JSON.parse(response.body)['freeShipping']
    end
    
    def get_api_info(sup, agent)
        api_endpoint = "https://www.netshoes.com.br/refactoring/tpl/frdmprcs/#{sup[:sku]}/lazy/b" 
        response = agent.get(api_endpoint) 
        if response
            sup[:sku_ref] = response.search('section').attr('data-sku-ref').value                                                                                                                                                                                                                                                      
            sup[:seller_code] = response.search('section').attr('data-seller-ref').value
            api_promo = response.search('.stamp-coupon')
            sup[:promo] = handle_promos(sup, api_promo)
        end
        sup
    end

    def handle_promos(sup, api_promo)
        if sup[:promo] && api_promo.present?
            sup[:promo] = "#{sup[:promo]} #{api_promo.text.strip()}" 
        elsif api_promo.present?
            sup[:promo] = api_promo.text.strip() 
        end
        sup[:promo]
    end

end
