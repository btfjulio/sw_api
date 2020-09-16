
# AMAZON SCRAPERS

desc 'Scrape Amazon'
task scrape_amazon: :environment do
    amz = AmazonScraper.new()
    amz.access_api()
end

desc 'Scrape Amazon Website'
task scrape_amazon_website: :environment do
    amz = AmzScraper.new()
    amz.scrapy()
end

desc 'Test API'
task test_amazon_api: :environment do
    amz = AmazonApi.new()
    amz.get_product()
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
        store_id: Store.find_by(name: 'Corpo Perfeito').id
    })
    cp.access_api()
end

desc 'Scrape Corpo Perfeito Product Page'
task scrape_product_cp: :environment do
    cp = SaudiProductScraper.new({
        store: 'lojacorpoperfeito',
        seller: 'Corpo Perfeito',
        store_code: 'cp',
        store_id: Store.find_by(name: 'Corpo Perfeito').id
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

# MADRUGAO SCRAPER

desc 'Scrape madrugao suplement index pages'
task scrape_madrugao_index: :environment do
    index_scraper = Suplement::Madrugao::IndexScraper.new()
    index_scraper.get_products()
end