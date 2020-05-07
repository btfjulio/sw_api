
class Equipment::Netshoes::IndexScraper

  # html index products Nethoes sctructure
  STRUCTURE = {
    sku: {
        tag: 'parent-sku',
    },
    link:{
        link: '.item-card__description__product-name',
        method: Proc.new { |content| "https://ad.zanox.com/ppc/?37530276C20702613&ULP=[[https:#{content['href']}?campaign=compadi]]" }
    },
    name:{
        tag: '.item-card__description__product-name',
        method: Proc.new { |content| content.text.strip() }
    },
    photo_url:{
        tag: '.item-card__images__image-link img',
        method: Proc.new { |content| content['data-src'] }
    }
  }

  def initialize()
    @crawler = Crawler.new()
    @page = 1
  end

  def get_products
    base_url = "https://www.netshoes.com.br/fitness-e-musculacao?campaign=compadi"
    last_page = get_last_page(base_url)
    while @page <= last_page
      puts "Scrapping #{base_url}&page=#{@page}"
      parse_page(@crawler.get_page("#{base_url}&page=#{@page}"))
      @page += 1
    end
  end
  
  def get_last_page(base_url)
    doc = @crawler.get_page(base_url)
    last_page = @crawler.get_content('.last', doc) { |content| content.text.strip().to_i }
  end

  def parse_page(page_html)
    @crawler.get_products(page_html, '.item-card').each do |product|
        equipment = parse_product(product)
        db_product = Equipment.where(store_code: equipment[:sku])
        db_product.nil? ? save(equipment) : update(equipment, equipment[:sku])
    end
  end

  def parse_product(equipment)
    STRUCTURE.keys.reduce(Hash.new(0)) do |response, info|
      binding.pry 
      tag = STRUCTURE[:info][:tag]
      method = STRUCTURE[:info][:method]
      response[:info] = @crawler.get_content(tag, equipment, &method)
      response
    end
  end

end
