require 'nokogiri'
require 'open-uri'
require 'mechanize'
# scrape to index product page

# rake collect_sup_description_infos
class BaseDescriptionScraper
  # Access-Control-Allow-Headers, x-requested-with, x-requested-by
  
  def initialize(options = {})
    @agent = Mechanize.new
    @product = options[:product]
    @headers = create_headers()
  end
	
  def get_product_infos
	api_info = get_api_info
	api_info.nil? | api_info.empty? ? (return false) : description = parse_info(api_info) 
	@product.update(description: description)
	puts "#{@product.name} Product Page infos collected"
  end

  def make_request
	retries ||= 0
	puts "Getting #{@product.name} info"
	product_code = @product.store_code.gsub(/\D/,'')
	api_endpoint = "https://api.saudifitness.com.br/api/v2/produto/informacao/#{product_code}/1/1/false"
	@headers[:referer] = gen_referer()
	@agent.request_headers = @headers
	response = @agent.get(api_endpoint)
	JSON.parse(response.body)
  rescue StandardError => e
	puts e
	puts "error.. retrying after a min"
	sleep 3
	if retries <= 3
	  retries += 1
	  retry
	end
  end
	
  def gen_referer
	referer_adapt = @product.link.match(/(?<=produto\/)(.*)(?=&utm)/)
	"https://www.lojacorpoperfeito.com.br/produto/#{referer_adapt}"
  end
	
  def get_api_info
	if BaseSuplement.find(@product.id).description
      puts "#{@product.name} already checked"
	else
	  sleep 1
      make_request
	end
  end
  
  def parse_info(api_info)
	product_info = api_info.select {|info| info["chave"] == "Informações" }
	product_info.empty? ? false : product_info.first["valor"]
  end
	
  def create_headers
	{
		"authority": "api.saudifitness.com.br",
		"pragma": "no-cache",
		"cache-control": "no-cache",
		"accept": "*/*",
		"agent": " Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36",
		"origin": "https://www.lojacorpoperfeito.com.br",
		"sec-fetch-site": "cross-site",
		"sec-fetch-mode": "cors",
		"sec-fetch-dest": "empty",
		"accept-language": "en-US,en;q=0.9,la;q=0.8"
    }
  end
	
end
