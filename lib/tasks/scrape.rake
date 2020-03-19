desc 'Scrape Netshoes'
task scrape_netshoes: :environment do
    netshoes = NetshoesScraper.new()
    netshoes.scrapy()
end

desc 'Scrape Amazon'
task scrape_amazon: :environment do
    amz = AmazonScraper.new()
    amz.read_json()
end

desc 'Scrape Amazon Website'
task scrape_amazon_wbsite: :environment do
    amz = AmzScraper.new()
    amz.scrapy()
end

desc 'Scrape Músculos na Web'
task scrape_mw: :environment do
    cp = MwScraper.new()
    cp.scrapy()
end

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

desc 'Scrape Corpo Ideal Product Page'
task scrape_product_ci: :environment do
    ci = CiProductScraper.new({
        store: 'corpoidealsuplementos',
        seller: 'Corpo Ideal',
        store_code: 'ci',
        store_id: 6
    })
    ci.get_product_infos()
end



desc 'Scrape Americanas'
task scrape_ame: :environment do
    ame_scraper = AmericanasScraper.new()
    ame_scraper.start_scraper()
end

desc 'Scrape Netshoes API'
task scrape_netshoes_api: :environment do
    api_scraper = NetshoesScraperApi.new()
    api_scraper.access_api()
end

