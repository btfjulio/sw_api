class Suplement::Madrugao::IndexScraper
  # html index products Nethoes sctructure
  STRUCTURE = {
    name: {
      tag: '.product-name',
      method: proc { |content| content.text.strip }
    }
  }.freeze

  def initialize(options = {})
    @crawler = Crawler.new
    @product = options[:product]
  end
  
  def get_products
    puts "Scrapping #{base_url}&page=#{@page_link}"
    current_page = @crawler.get_page("#{base_url}&page=#{@page_link}")
    suplement = parse_product(current_page)
    
    binding.pry
    
    if suplement
      suplement = index_page_info.merge(api_product_info)
      DbHandler.save_product(suplement)
    else
      DbHandler.delete_product(suplement)
    end
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
