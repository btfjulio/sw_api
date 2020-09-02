class Suplement::Madrugao::ShowScraper
  # html index products Nethoes sctructure
  STRUCTURE = {
    store_code: {
      tag: "meta[itemprop='sku']",
      method: proc { |content| content&.attribute('content')&.value }
    },
    # description: {
    #   tag: ".box-description .std",
    #   method: proc { |content| content.text.strip }
    # }
  }.freeze

  def initialize(options = {})
    @crawler = Crawler.new
    @product = options[:product]
  end

  def get_product
    puts "Scrapping #{@product[:name]} page"
    current_page = @crawler.get_page(@product[:link])
    @crawler.parse_product(STRUCTURE, current_page)
  end

end
