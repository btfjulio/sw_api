class AddPriceToSuplementos < ActiveRecord::Migration[5.2]
  def change
    add_monetize :suplementos, :price, currency: { present: false }
  end
end
