class NetshoesUpdater

    def check_stock
        puts 'Starting updater'
        netshoes_products = Suplemento.where(store_id: 2).order('(price_cents - average) / (average / 100)')
        agent = start_crawler()
        out_stock_sups = crawl_netshoes_sups(agent, netshoes_products)
        puts 'Finishing updater'       
    end
    
    def start_crawler
        agent = Mechanize.new
        agent.user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
        agent    
    end

    def crawl_netshoes_sups(agent, netshoes_products)
        netshoes_products.select { |sup| check_prod_stock(sup.link, agent, sup) }
    end

    def check_prod_stock(link, agent, sup)
        begin
            retries ||= 0   
            doc = agent.get(link)
        rescue
            sleep 3
            retry if ( retries +=1 ) < 3
        end
        return true if doc == nil
        out_stock_tag = doc.search('.tell-me-button-wrapper .title')
        not_available_tag = doc.search('.text-not-avaliable')
        deleted_message = doc.search('.message > p')
        if out_stock_tag.present? && out_stock_tag.first.text == "Produto indisponível"
            sup.destroy
        elsif not_available_tag.present? && not_available_tag.first.text.match(/acabou/)
            sup.destroy
        else
            puts 'ok'
            false
        end
    end
end
