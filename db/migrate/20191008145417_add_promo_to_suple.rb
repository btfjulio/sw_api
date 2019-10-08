class AddPromoToSuple < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :promo , :string
  end
end
