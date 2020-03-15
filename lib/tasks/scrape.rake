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



desc 'Scrape Corpo Perfeito'
task scrape_cp: :environment do
    cp = CpScraper.new()
    cp.scrapy()
end


desc 'Scrape Músculos na Web'
task scrape_mw: :environment do
    cp = MwScraper.new()
    cp.scrapy()
end

desc 'Scrape Músculos na Web'
task scrape_centauro: :environment do
    cp = CentauroScraper.new()
    cp.access_api()
end

desc 'Scrape Corpo Ideal Index Page'
task scrape_ci: :environment do
    ci = CiScraper.new()
    ci.access_api()
end

desc 'Scrape Corpo Ideal Product Page'
task scrape_product_ci: :environment do
    ci = CiProductScraper.new()
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

