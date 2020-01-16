class NetshoesUpdater

    def check_stock
        puts 'Starting updater'
        netshoes_products = Suplemento.where(store_id: 2)
        agent = start_crawler()
        out_stock_sups = crawl_netshoes_sups(agent, netshoes_products)
        delete_sups(out_stock_sups)
        puts 'Finishing updater'       
    end
    
    def start_crawler
        agent = Mechanize.new
        agent.user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
        agent    
    end
    
    def delete_sups(out_stock_sups)
        out_stock_sups.each do |sup| 
            sup.destroy 
            puts "#{sup.name} deleted" 
        end
    end

    def crawl_netshoes_sups(agent, netshoes_products)
        netshoes_products.select { |sup| check_prod_stock(sup.link, agent) }
    end

    def check_prod_stock(link, agent)
        begin
            retries ||= 0   
            doc = agent.get(link)
        rescue
            sleep 3
            retry if ( retries +=1 ) < 3
        end
        puts "crawling #{link}"
        out_stock_tag = doc.search('.tell-me-button-wrapper .title')
        not_available_tag = doc.search('.text-not-avaliable')
        deleted_message = doc.search('.message > p')
        if out_stock_tag.present? && out_stock_tag.first.text == "Produto indisponível"
            true 
        elsif not_available_tag.present? && not_available_tag.first.text.match(/acabou/)
            true 
        else
            puts 'ok'
            false
        end
    end
end
