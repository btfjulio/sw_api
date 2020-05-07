

class ShowEquipmentPage

    STRUCTURE = {
        price: {
            tag: '.default-price',
            method: Proc.new { |content| content.text.strip() }
        },
        sender:{
            tag: '.dlvr',
            method: Proc.new { |content| content.text.strip() }
        },
        flavor:{
            tag: '.sku-select .item a',
            method: Proc.new { |content| content.text.strip() }
        },
        promo:{
            tag: '.badge-item',
            method: Proc.new { |content| content.text.strip() }
        },
        seller:{
            tag: '.product__seller_name span',
            method: Proc.new { |content| content.text.strip() || "Netshoes" }
        }
    }
    
    
    def get_page
        puts "Scrapping #{sup[:name]}"
        if doc 
            
        else
            return sup
        end
        connect_to_api(sup)
    end
    
    # simulates client side requests from netshoes api
    def connect_to_api(sup)
        begin
        sup = @netshoes_api.access_api(sup)
        rescue => e
        sleep 3
        puts 'problem in the netshoes api'
        retry
        end
    end

    def parse_page(sup)
        STRUCTURE.keys.reduce(Hash.new(0)) do |response, info|
            tag = STRUCTURE[:info][:tag]
            method = STRUCTURE[:info][:method]
            response[:info] = @crawler.get_content(tag, doc, &method)
            respose
        end
    end
end