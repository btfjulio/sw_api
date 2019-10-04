class AddPriceChangedToSuplementos < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :price_changed , :boolean
  end
end
