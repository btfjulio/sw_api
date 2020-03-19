class AddBrandCodeToSuplementos < ActiveRecord::Migration[5.2]
  def change
      add_column :suplementos, :brand_code, :string
  end
end
