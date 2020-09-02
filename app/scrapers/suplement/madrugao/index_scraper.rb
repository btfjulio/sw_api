class Suplement::Madrugao::IndexScraper
  # html index products Nethoes sctructure
  STRUCTURE = {
    link: {
      tag: '.product-image',
      method: proc do |content|
        
        binding.pry
        
        "#{content['href']}?utm_source=savewhey&utm_medium=savewhey&utm_campaign=#{content['href'].gsub('', '')}"
      end
    },
    name: {
      tag: '.product-name',
      method: proc { |content| content.text.strip }
    },
    photo: {
      tag: 'img.product-collection-image-8080',
      method: proc { |content| content['data-src'] }
    },
    price: {
      tag: '.special-special-price',
      method: proc { |content| content.text.gsub(/\D/, '').to_i }
    },
    brand: {
      tag: '.manufacturer',
      method: proc { |content| content.text.strip }
    }
  }.freeze

  def initialize
    @crawler = Crawler.new
    @page_link = ''
    @structures = [
      { url: 'https://www.madrugaosuplementos.com.br/ganhar_peso/' },
      { url: 'https://www.madrugaosuplementos.com.br/massa_muscular/' },
      { url: 'https://www.madrugaosuplementos.com.br/emagrecer/' },
      { url: 'https://www.madrugaosuplementos.com.br/ganhar_peso/' },
      { url: 'https://www.madrugaosuplementos.com.br/aumentar_energia/' },
      { url: 'https://www.madrugaosuplementos.com.br/definicao_muscular/' }
    ]
    base_url = 'https://www.madrugaosuplementos.com.br/'
  end

  def get_products
    @structures.each do |structure|
      @page_link = get_last_page(structure[:url])
      while @page_link
        puts "Scrapping #{base_url}&page=#{@page_link}"
        current_page = @crawler.get_page("#{base_url}&page=#{@page_link}")
        parse_page(current_page)
        @page_link = get_last_page(structure[:url])
      end
    end
  end

  def get_next_page(base_url)
    doc = @crawler.get_page(base_url)
    last_page = @crawler.get_content('.i-next', doc) { |content| content.text.strip }
  end

  def parse_page(page_html)
    @crawler.get_products(page_html, '.item.last').each do |product|
      index_page_info = parse_product(product)
      api_product_info = get_api_info(index_page_info)
      if api_product_info
        # show_page_info = get_product_page(index_page_info)
        suplement = index_page_info.merge(api_product_info)
        save_on_db(suplement)
      else
        delete_on_db(product)
      end
    end
  end

  def delete_on_db(suplement)
    db_product = Suplemento.where(store_code: suplement[:store_code])
    unless db_product.empty?
      deleted_prod = db_product.delete
      puts "#{deleted_prod.name} deleted on DB"
    end
  end

  def save_on_db(suplement)
    db_product = Suplemento.where(store_code: suplement[:store_code])
    saved_prod = (db_product.empty? ? Suplemento.create(suplement) : db_product.update(suplement).first)
    puts "#{saved_prod.name} saved on DB"
  end

  def parse_product(suplement)
    STRUCTURE.keys.each do |info|
      tag = STRUCTURE[info.to_sym][:tag]
      method = STRUCTURE[info.to_sym][:method]
      parsed_equip[info.to_sym] = @crawler.get_content_proc(tag, suplement, &method)
    end
    parsed_equip
  end
end
