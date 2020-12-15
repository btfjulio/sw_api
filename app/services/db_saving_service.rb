class DbSavingService
  def initialize(product)
    @product = product
  end

  def call 
      sup = Suplemento.find_by(store_code: @product[:store_code]) 
      sup.present? ? sup.update(@product) : Suplemento.create(@product) 
    rescue StandardError => e
      binding.pry
  end

end