require 'nokogiri'
require 'open-uri'
require 'mechanize'
# scrape to index product page

class SaudiScraper
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
    @store_id = options[:store_id]
    @store_code = options[:store_code]
    @seller = options[:seller]
    @headers = create_headers
  end

  def access_api
    agent = create_crawler
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
        break if all_unavailable?(info)
        get_products(info)
        sleep 100
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
      if product["Disponivel"]
        product = serialize_product(product)
        puts product
        DbHandler.save_product(product)
      else
        DbHandler.delete_product(product)
      end
    end
  end

  def all_unavailable?(info)
    info["lista"].count { |item| item["Disponivel"] == false } == 12
  end

  def serialize_product(info)
    {
      price: info["Precovista"] * 100,
      link: "https://www.#{@store}.com.br/produto/#{info['GradeAlias']}?s=#{info['ID']}&utm_source=savewhey&vp=savewhey11",
      photo: "https://produto.saudifitness.com.br//460x460/#{info['ID']}.jpg/flags?aplicarFlags=true&amp;unidade=4&amp;v=11",
      name: info["NomeCompleto"],
      store_code: "#{@store_code}-#{info['ID']}",
      brand_code: info["FabricanteID"]&.to_s,
      brand: info["FabricanteNome"],
      seller: "Corpo Perfeito",
      auxgrad: info["auxGradeID"],
      combo: info["Combo"] ? "true" : "false",
      category: info["CategoriaAlias"],
      subcategory: info["SubcategoriaAlias"],
      flavor: info["SaborAlias"],
      ean: info["EAN"].strip,
      store_id: 4
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
