class Suplement::Madrugao::IndexScraper
  # html index products Nethoes sctructure
  STRUCTURE = {
    link: {
      tag: '.product-image',
      method: proc do |content|
        campaign = content['href'][0...-1].gsub('https://www.madrugaosuplementos.com.br/', '')
        "#{content['href']}?utm_source=savewhey&utm_medium=savewhey&utm_campaign=#{campaign}"
      end
    },
    name: {
      tag: '.product-name',
      method: proc { |content| content.text.strip }
    },
    photo: {
      tag: '.product-image img',
      method: proc { |content| content['src'] }
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
      { url: 'https://www.madrugaosuplementos.com.br/ganhar_peso' },
      { url: 'https://www.madrugaosuplementos.com.br/massa_muscular' },
      { url: 'https://www.madrugaosuplementos.com.br/emagrecer' },
      { url: 'https://www.madrugaosuplementos.com.br/ganhar_peso' },
      { url: 'https://www.madrugaosuplementos.com.br/aumentar_energia' },
      { url: 'https://www.madrugaosuplementos.com.br/definicao_muscular' }
    ]
    @base_url = 'https://www.madrugaosuplementos.com.br/'
  end

  def get_products
    @structures.each do |structure|
      @page_link = structure[:url]
      while @page_link
        puts "Scrapping #{@page_link}"
        current_page = @crawler.get_page(@page_link)
        parse_page(current_page)
        @page_link = get_next_page
      end
    end
  end

  def get_next_page
    doc = @crawler.get_page(@page_link)
    @crawler.get_content('.i-next', doc) { |content| content['href'] }
  end

  def parse_page(page_html)
    @crawler.get_products(page_html, '.item.last').each do |product_tag|
      index_page_info = @crawler.parse_product(STRUCTURE, product_tag)
      show_page_info = Suplement::Madrugao::ShowScraper
                       .new(product: index_page_info)
                       .get_product
      handle_db(index_page_info, show_page_info)
    end
  end

  def handle_db(index_page_info, show_page_info)
    if index_page_info && show_page_info
      suplement = index_page_info
                  .merge(show_page_info)
                  .merge(store_id: 7)
      DbHandler.save_product(suplement)
    else
      # DbHandler.delete_product(suplement)
    end
  end

  def get_script(doc)
    scripts = doc.search('script')
    target_script = scripts.select do |script|
      script.text.match(/"ecomm_prodid":/)
    end
  end

  def parse_script(target_script)
    json_string = URI.decode(target_script.first.text)
    json_string.gsub!(/window.__PRELOADED_STATE__ = "/, "")
    parsed_json = JSON.parse(json_string[0..-3])
  end

end
