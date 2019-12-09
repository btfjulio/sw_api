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
    cp.scrapy()
end

desc 'Scrape Corpo Ideal'
task scrape_ci: :environment do
    cp = CiScraper.new()
    cp.scrapy()
end