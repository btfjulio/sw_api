class AddProductCodeToBaseSuplements < ActiveRecord::Migration[5.2]
  def change
    add_column :base_suplements, :product_code, :integer
  end
end
