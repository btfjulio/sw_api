require 'nokogiri'
require 'open-uri'
require 'mechanize'
# scrape to index product page
# rake collect_sup_infos

class BaseSupsScraper
  # Access-Control-Allow-Headers, x-requested-with, x-requested-by


  def initialize(options = {})
    @page = 1
    @structures = [
        { proteinas: "2455" }, { aminos: "2474" }, { pre_treinos: "2471" }, 
        { carboidratos: "2480" }, { emagrecedores: "2514" }, { gourmet: "2531" }, 
        { vitaminas: "2499" }, { hipercaloricos: "2469"}, { zma: "2470" },
        { vasodilatadores: "2472" }, { packs: "2473"}, { colageno: "2498"},
        { fiterapicos: "2489"}, { acessorios: "2523"}   
    ]
    @store =  options[:store]
    @store_code = options[:store_code]
    @headers = create_headers
  end

  def access_api
    puts "Collection initialized"
    agent = create_crawler
    puts "Crawler created"
    get_api_info(agent)
    puts "#{@store} infos collected"
  end

  def create_crawler
    agent = Mechanize.new
    agent.request_headers = @headers
    agent.user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    agent
  end

  def get_api_info(agent)
    @structures.each do |structure|
      info = make_request(agent, structure)
      last_page = get_last_page(info)
      while @page <= last_page
        info = make_request(agent, structure)
        puts "Product info colected"
        get_products(info)
        sleep 1
        @page += 1
      end
      @page = 1
    end
  end

  def make_request(agent, structure)
    retries ||= 0
    api_endpoint = "https://api.saudifitness.com.br/api/v2/categoria/spots/filtro"
    request_body = create_request_body(structure.values.first)
    response = agent.post(api_endpoint, request_body)
    JSON.parse(response.body)
  rescue StandardError => e
    puts e
    puts "error.. retrying after a min"
    sleep 30
    if retries <= 1
      retries += 1
      retry
    end
  end

  def get_last_page(info)
    info['TotalPaginas'].to_i
  end

  def get_products(info)
    info['lista'].each do |product|
      unless product["Combo"]
        new_base_sup = serialize_product(product)
        new_base_sup[:brand_id] = get_brand_id(product["FabricanteNome"]) 
        begin
          save_product(new_base_sup)
        rescue => exception
          binding.pry
        end
      end
    end
  end

  def save_product(new_base_sup)
    db_product = BaseSuplement.where(store_code: new_base_sup[:store_code]).first
    if db_product
      db_product.update(new_base_sup)
      puts "#{new_base_sup[:name]} updated on DB"
    else
      BaseSuplement.create!(new_base_sup)
      puts "#{new_base_sup[:name]} created on DB"
    end
  end

  def get_brand_id(brand)
    product_brand = I18n.transliterate(brand.gsub(' ', ''))
    brand = Brand.search_name(product_brand)&.first
    brand ? brand.id : nil 
  end

  def serialize_product(info)
    {
      photo: "https://produto.saudifitness.com.br//460x460/#{info['ID']}.jpg/flags?aplicarFlags=true&amp;unidade=4&amp;v=11",
      name: info["NomeCompleto"],
      link: "https://www.#{@store}.com.br/produto/#{info['GradeAlias']}?s=#{info['ID']}&utm_source=savewhey&vp=savewhey11",
      store_code: "#{@store_code}-#{info['ID']}",
      brand_code: info["FabricanteID"]&.to_s,
      brand_id: get_brand_id(info["FabricanteID"]&.to_s),
      brand_name: info["FabricanteNome"],
      auxgrad: info["auxGradeID"],
      category: info["CategoriaAlias"],
      subcategory: info["SubcategoriaAlias"],
      flavor: info["SaborAlias"],
      ean: info["EAN"].strip
    }
  end

  def create_request_body(structure_code)
    {
      "idEstrutura": structure_code,
      "idTipoEstrutura": "categoria",
      "idapp": "13",
      "idun": "4",
      "netapp": "False",
      "pagina": @page,
      "filtroscarregados": false,
      "ordenacao": 1,
      "hascookie": false
    }
  end

  def create_headers
    {
      "authority": "api.saudifitness.com.br",
      "accept": "application/json, text/plain, */*",
      "sec-fetch-dest": "empty",
      "user-agent": "Mozilla/5.0 (Linux; U; Android 4.4.2; en-us; SCH-I535 Build/KOT49H) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
      "content-type": "application/json;charset=UTF-8",
      "origin": "https://m.#{@store}.com.br",
      "sec-fetch-site": "cross-site",
      "sec-fetch-mode": "cors",
      "referer": "https://m.#{@store}.com.br//proteinas?_ggCurrentURL=https%3A%2F%2Fwww.#{@store}.com.br%2Fproteinas%3F_ggRedir%3Dm&_ggReferrerURL=https%3A%2F%2Fwww.#{@store}.com.br%2F",
      "accept-language": "en-US,en;q=0.9,la;q=0.8"
    }
  end

end
