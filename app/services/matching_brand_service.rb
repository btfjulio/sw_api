class MatchingBrandService
  def initialize(brand)
    @brand_name = brand.parameterize.gsub('-', '') if brand
  end

  def call 
    return nil unless @brand_name
    brand = Brand.search_name_trigram(@brand_name)
    brand.present? ? brand.first : nil
  end
end