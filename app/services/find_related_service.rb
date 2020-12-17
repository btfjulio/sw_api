class FindRelatedService
  attr_reader :product, :related_prods

  def initialize(product)
    @product = product
    @name = product.name.parameterize.gsub("-", '')
  end

  def call
    @related_prods = Suplemento
                      .where(brand: product.brand)
                      .find_related(@product.name)
    # filter_by_brand
  end

  def filter_by_brand 

  end
  
end