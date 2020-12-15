class DbDeletingService
  def initialize(product)
    @product = product
  end

  def call 
    Suplemento.find_by(store_code: @product[:store_code])&.destroy
  end

end