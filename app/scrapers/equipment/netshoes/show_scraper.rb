

class Equipment::Netshoes::ShowScraper
    #  available sizes, prices, seller and sender
    STRUCTURE = {
        price: {
            tag: '.default-price',
            method: Proc.new { |content| content.text.strip() }
        },
        sender:{
            tag: '.product-seller-info',
            method: Proc.new { |content| content.text.strip() }
        },
        seller:{
            tag: '.product__seller_name > span',
            method: Proc.new do |content|
                content.nil? ? 'Netshoes' : content.text.strip() 
            end
        }
    }
    
    def initialize(options = {})
        @crawler = Crawler.new()
        @product = options[:product]
    end
    
    def get_page
        puts "Scrapping #{@product[:name]}"
        equipment = @crawler.get_page(@product[:link])
        parse_product(equipment)
    end
    

    def parse_product(equipment)
        parsed_equip = {}
        STRUCTURE.keys.each do |info|
            tag = STRUCTURE[info.to_sym][:tag]
            method = STRUCTURE[info.to_sym][:method]
            parsed_equip[info.to_sym] = @crawler.get_content_proc(tag, equipment, &method)
        end
        parsed_equip[:sizes] = get_sizes(equipment)
        # if tag does not exist is sold by Netshoes
        parsed_equip[:seller] = parsed_equip[:seller] || "Netshoes"
        parsed_equip
    end

    def get_sizes(equipment)
        size_elemts = equipment.search('.product-size-selector .radio-options li:not(.unavailable)')    
        size_elemts.map { |li| li.text.strip() }.uniq.join(",")
    end
end