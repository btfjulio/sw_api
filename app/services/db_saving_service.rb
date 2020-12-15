class DbSavingService
  def initialize(product)
    @product = product
  end

  def call 
    sup = Suplemento.find_by(store_code: @product[:store_code]) 
    sup ? Suplemento.create(@product) : sup.update(@product)
  end

end