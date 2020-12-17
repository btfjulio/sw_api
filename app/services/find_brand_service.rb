class FindBrandService 

  def initialize(product)
    @product = product
  end

  def call 
    Brand.all.find do |current_brand|
      normalized_name = @product.name.parameterize.gsub('-', '')
      normalized_name.match?(current_brand.match_pattern) 
    end
  end
end