class AddInfoToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :suplementos, :ean, :string
    add_column :suplementos, :category, :string
    add_column :suplementos, :subcategory, :string
    add_column :suplementos, :combo, :string
  end
end
