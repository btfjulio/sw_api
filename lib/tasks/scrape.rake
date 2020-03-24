

# NETSHOES TASKS SCRAPERS

'Scrape Netshoes'
task scrape_netshoes: :environment do
    netshoes = NetshoesScraper.new()
    netshoes.scrapy()
end

desc 'Scrape Netshoes API'
task scrape_netshoes_api: :environment do
    api_scraper = NetshoesScraperApi.new()
    api_scraper.access_api()
end

desc 'Scrape Netshoes Products API'
task scrape_netshoes_product: :environment do
    def save_product(product, suplemento)
        if product == false 
            puts "Suplemento #{suplemento.name} DESTROYED on DB"
            suplemento.destroy() 
        else 
            puts "Suplemento #{suplemento.name} UPDATED on DB"
            suplemento.update(product)
        end 
    end

    Suplemento.where(store_id: 2).each do |suplemento|
        api_scraper = NetshoesProductScraper.new({
            product: suplemento
        })
        product = api_scraper.get_product_infos()
        save_product(product, suplemento)
    end
end

# AMAZON SCRAPERS

desc 'Scrape Amazon'
task scrape_amazon: :environment do
    amz = AmazonScraper.new()
    amz.read_json()
end

desc 'Scrape Amazon Website'
task scrape_amazon_website: :environment do
    amz = AmzScraper.new()
    amz.scrapy()
end


# MUSCULOS NA WEB SCRAPERS

# desc 'Scrape Músculos na Web'
# task scrape_mw: :environment do
#     # partnership stopped
#     # cp = MwScraper.new()
#     # cp.scrapy()
# end

# CENTAURO SCRAPERS

desc 'Scrape Centauro'
task scrape_centauro: :environment do
    cp = CentauroScraper.new()
    cp.access_api()
end

# SAUDI FITNESS SCRAPERS

desc 'Scrape Corpo Ideal Index Page'
task scrape_ci: :environment do
    ci = SaudiScraper.new({
        store: 'corpoidealsuplementos',
        seller: 'Corpo Ideal',
        store_code: 'ci',
        store_id: 6
    })
    ci.access_api()
end

desc 'Scrape Corpo Perfeito'
task scrape_cp: :environment do
    cp = SaudiScraper.new({
        store: 'lojacorpoperfeito',
        seller: 'Corpo Perfeito',
        store_code: 'cp',
        store_id: 4
    })
    cp.access_api()
end

desc 'Scrape Corpo Perfeito Product Page'
task scrape_product_cp: :environment do
    cp = SaudiProductScraper.new({
        store: 'lojacorpoperfeito',
        seller: 'Corpo Perfeito',
        store_code: 'cp',
        store_id: 4
    })
    cp.get_product_infos()
end

desc 'Scrape Corpo Ideal Product Page'
task scrape_product_ci: :environment do
    ci = SaudiProductScraper.new({
        store: 'corpoidealsuplementos',
        seller: 'Corpo Ideal',
        store_code: 'ci',
        store_id: 6
    })
    ci.get_product_infos()
end

# AMERICANAS SCRAPERS

desc 'Scrape Americanas'
task scrape_ame: :environment do
    ame_scraper = AmericanasScraper.new()
    ame_scraper.start_scraper()
end

