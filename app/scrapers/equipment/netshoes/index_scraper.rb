
class Equipment::Netshoes::IndexScraper

  # html index products Nethoes sctructure
  STRUCTURE = {
    link:{
        tag: '.item-card__description__product-name',
        method: Proc.new { |content| "https://ad.zanox.com/ppc/?37530276C20702613&ULP=[[https:#{content['href']}?campaign=compadi]]" }
    },
    name:{
        tag: '.item-card__description__product-name',
        method: Proc.new { |content| content.text.strip() }
    },
    photo:{
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
      index_page_info = parse_product(product)
      api_product_info = get_api_info(index_page_info)
      if api_product_info
        # show_page_info = get_product_page(index_page_info)
        equipment = index_page_info.merge(api_product_info)
        save_on_db(equipment)
      else
        delete_on_db(product)
      end
    end
  end
    
  def delete_on_db(equipment)
    db_product = Equipment.where(store_code: equipment[:store_code])
    unless db_product.empty? 
      deleted_prod = db_product.delete
      puts "#{deleted_prod.name} deleted on DB"
    end
  end

  def save_on_db(equipment)
    db_product = Equipment.where(store_code: equipment[:store_code])
    saved_prod = (db_product.empty? ? Equipment.create(equipment) : db_product.update(equipment).first)
    puts "#{saved_prod.name} saved on DB"
  end

  def parse_product(equipment)
    parsed_equip = { store_code: equipment['parent-sku'] }
    STRUCTURE.keys.each do |info|
      tag = STRUCTURE[info.to_sym][:tag]
      method = STRUCTURE[info.to_sym][:method]
      parsed_equip[info.to_sym] = @crawler.get_content_proc(tag, equipment, &method)
    end
    parsed_equip
  end

  def get_product_page(equipment)
    show_page_scraper = Equipment::Netshoes::ShowScraper.new(product: equipment)
    show_page_scraper.get_page
  end

  def get_api_info(equipment)
    show_page_scraper = Equipment::Netshoes::ApiProductScraper.new(product: equipment)
    show_page_scraper.get_product_infos
  end
end


