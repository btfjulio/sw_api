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