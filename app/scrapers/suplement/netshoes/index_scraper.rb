
class Suplement::Netshoes::IndexScraper
  # html index products Nethoes sctructure
  STRUCTURE = {
    link: {
      tag: '.item-card__description__product-name',
      method: proc do |content|
                link = CGI.escape(content['href'])
                "https:#{link}?campaign=compadi"
              end
    },
    name: {
      tag: '.item-card__images__image-link',
      method: proc { |content| content['title'] }
    },
    photo: {
      tag: '.item-card__images__image-link img',
      method: proc { |content| content['data-src'] }
    }
  }.freeze

  def initialize
    @crawler = Crawler.new
    @page = 1
  end

  def get_products
    base_url = 'https://www.netshoes.com.br/suplementos?campaign=compadi'
    last_page = get_last_page(base_url)
    while @page <= last_page
      puts "Scrapping #{base_url}&page=#{@page}"
      parse_page(@crawler.get_page("#{base_url}&page=#{@page}"))
      @page += 1
    end
  end

  def get_last_page(base_url)
    doc = @crawler.get_page(base_url)
    @crawler.get_content('.last', doc) { |content| content.text.strip.to_i }
  end

  def parse_page(page_html)
    @crawler.get_products(page_html, '.item-card').each do |product|
      index_page_info = parse_product(product)
      api_product_info = get_api_info(index_page_info)
      if api_product_info
        # show_page_info = get_product_page(index_page_info)
        suplement = index_page_info.merge(api_product_info)
        DbSavingService.new(suplement).call
      else  
        DbDeletingService.new(product).call
      end
    end
  end

  def parse_product(suplement)
    parsed_equip = { store_code: suplement['parent-sku'] }
    STRUCTURE.keys.each do |info|
      tag = STRUCTURE[info.to_sym][:tag]
      method = STRUCTURE[info.to_sym][:method]
      parsed_equip[info.to_sym] = @crawler.get_content_proc(tag, suplement, &method)
    end
    parsed_equip
  end

  def get_api_info(suplement)
    show_page_scraper = Suplement::Netshoes::ApiProductScraper.new(product: suplement)
    show_page_scraper.get_product_infos
  end
end
